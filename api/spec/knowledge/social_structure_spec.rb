# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '群れと社会構造' do
  def savanna(capacity: 4, temp: 28)
    build(:enclosure, name: 'ライオンの丘', temperature: Temperature.celsius(temp), capacity:)
  end

  describe '序列と余剰オス' do
    context '群れ性の種で成熟したオスが複数同居すると' do
      it '最も年長でない(序列下位の)オスは闘争でストレスを受けること' do
        enclosure = savanna
        senior = build(:animal, name: '長老', age_in_days: 4000)
        junior = build(:animal, name: '若オス')
        occupants = [senior, junior]

        expect(build(:welfare, animal: junior, enclosure:, occupants:).daily_stress).to be > 0
      end

      it '最も年長のオス(優位)はストレスを受けないこと' do
        enclosure = savanna
        senior = build(:animal, name: '長老', age_in_days: 4000)
        junior = build(:animal, name: '若オス')
        occupants = [senior, junior]

        expect(build(:welfare, animal: senior, enclosure:, occupants:).daily_stress).to be < 0
      end
    end

    context '成熟したオスが1頭だけのとき' do
      it '序列闘争は起きないこと' do
        enclosure = savanna
        male = build(:animal, name: 'オス')
        female = build(:animal, :female, name: 'メス')
        occupants = [male, female]

        expect(build(:welfare, animal: male, enclosure:, occupants:).daily_stress).to be < 0
      end
    end
  end
end
