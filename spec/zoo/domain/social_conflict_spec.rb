# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe SocialConflict do
      let(:lion) { SpeciesCatalog.lion }
      let(:zebra) { SpeciesCatalog.grevys_zebra }

      def pen(name = '丘', capacity: 6, area_sqm: nil)
        Enclosure.new(name: name, temperature: Shared::Temperature.celsius(28), capacity: capacity, area_sqm: area_sqm)
      end

      def conflict(enclosure, occupants, animal)
        described_class.new(enclosure, occupants, animal)
      end

      describe '#subordinate_male?' do
        it '成熟オスが複数いると、年長でない方が序列下位であること' do
          senior = build_animal(lion, name: '長老', sex: Animal::Sex.male, age_in_days: 4000)
          junior = build_adult(lion, name: '若', sex: Animal::Sex.male)
          occupants = [senior, junior]
          expect(conflict(pen, occupants, junior).subordinate_male?).to be(true)
          expect(conflict(pen, occupants, senior).subordinate_male?).to be(false)
        end

        it 'オス1頭・メス・未成熟は序列下位でないこと' do
          male = build_adult(lion, sex: Animal::Sex.male)
          female = build_adult(lion, sex: Animal::Sex.female)
          cub = build_animal(lion, name: '仔', sex: Animal::Sex.male, age_in_days: 0)
          occupants = [male, female, cub]
          expect(conflict(pen, occupants, male).subordinate_male?).to be(false)
          expect(conflict(pen, occupants, female).subordinate_male?).to be(false)
          expect(conflict(pen, occupants, cub).subordinate_male?).to be(false)
        end
      end

      describe '#injury' do
        it '序列下位でなければ0であること' do
          z = build_adult(zebra)
          expect(conflict(pen, [z], z).injury).to eq(0)
        end

        it '過密や逃げ場のなさは序列下位の外傷を加重すること' do
          senior = build_animal(lion, name: '長老', sex: Animal::Sex.male, age_in_days: 4000)
          junior = build_adult(lion, name: '若', sex: Animal::Sex.male)
          occupants = [senior, junior]
          cramped = pen('狭い丘', capacity: 4, area_sqm: 1)
          cramped.deplete_enrichment(100)
          spacious = pen('広い丘', capacity: 6)

          expect(conflict(cramped, occupants, junior).injury)
            .to be > conflict(spacious, occupants, junior).injury
        end
      end
    end
  end
end
