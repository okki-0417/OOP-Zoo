# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Companionship do
      let(:lion) { SpeciesCatalog.lion }
      let(:zebra) { SpeciesCatalog.grevys_zebra }

      def pen(name = '丘', capacity: 6, area_sqm: nil)
        Enclosure.new(name: name, temperature: Shared::Temperature.celsius(28), capacity: capacity, area_sqm: area_sqm)
      end

      def companionship(enclosure, occupants, member)
        described_class.new(enclosure: enclosure, occupancy: Occupancy.new(enclosure, occupants), member: member)
      end

      describe '#subordinate_male?' do
        it '成熟オスが複数いると、年長でない方が序列下位であること' do
          senior = build_animal(lion, name: '長老', sex: Animal::Sex.male, age_in_days: 4000)
          junior = build_adult(lion, name: '若', sex: Animal::Sex.male)
          occupants = [senior, junior]
          expect(companionship(pen, occupants, junior).subordinate_male?).to be(true)
          expect(companionship(pen, occupants, senior).subordinate_male?).to be(false)
        end

        it 'オス1頭・メス・未成熟は序列下位でないこと' do
          male = build_adult(lion, sex: Animal::Sex.male)
          female = build_adult(lion, sex: Animal::Sex.female)
          cub = build_animal(lion, name: '仔', sex: Animal::Sex.male, age_in_days: 0)
          occupants = [male, female, cub]
          expect(companionship(pen, occupants, male).subordinate_male?).to be(false)
          expect(companionship(pen, occupants, female).subordinate_male?).to be(false)
          expect(companionship(pen, occupants, cub).subordinate_male?).to be(false)
        end
      end

      describe '#injury' do
        it '序列下位でなければ0であること' do
          z = build_adult(zebra)
          expect(companionship(pen, [z], z).injury).to eq(0)
        end

        it '過密や逃げ場のなさは序列下位の外傷を加重すること' do
          senior = build_animal(lion, name: '長老', sex: Animal::Sex.male, age_in_days: 4000)
          junior = build_adult(lion, name: '若', sex: Animal::Sex.male)
          occupants = [senior, junior]
          cramped = pen('狭い丘', capacity: 4, area_sqm: 1)
          cramped.deplete_enrichment(100)
          spacious = pen('広い丘', capacity: 6)

          expect(companionship(cramped, occupants, junior).injury)
            .to be > companionship(spacious, occupants, junior).injury
        end
      end

      describe '#lonely?' do
        it '群れ性なのに同種の仲間がいないと孤独であること' do
          lone = build_adult(lion)
          expect(companionship(pen, [lone], lone).lonely?).to be(true)
        end

        it '同種の仲間がいれば孤独でないこと' do
          a = build_adult(lion, name: 'A')
          b = build_adult(lion, name: 'B', sex: Animal::Sex.female)
          expect(companionship(pen, [a, b], a).lonely?).to be(false)
        end
      end

      describe '#separated_dependent?' do
        it '未離乳で親が同居していないと分離されていること' do
          cub = Animal.new(species: lion, name: '仔', sex: Animal::Sex.male, max_health: 100,
                           age_in_days: 0, dam_id: Shared::Identifier.new)
          expect(companionship(pen, [cub], cub).separated_dependent?).to be(true)
        end

        it '離乳済みなら分離とみなされないこと' do
          weaned = build_adult(lion)
          expect(companionship(pen, [weaned], weaned).separated_dependent?).to be(false)
        end
      end
    end
  end
end
