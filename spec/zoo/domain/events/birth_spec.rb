# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Events::Birth do
  shared  = Zoo::Domain::Shared
  catalog = Zoo::Domain::SpeciesCatalog
  season  = Zoo::Domain::Season

  let(:offspring) { build_adult(catalog.lion, name: 'シンバ') }
  let(:sire_id) { shared::Identifier.new }
  let(:dam_id) { shared::Identifier.new }

  def build(occurred_on: 120, season: Zoo::Domain::Season.spring)
    described_class.new(offspring: offspring, sire_id: sire_id, dam_id: dam_id,
                        occurred_on: occurred_on, season: season)
  end

  describe '#initialize' do
    it '子・両親の識別子・発生日・季節を保持すること' do
      birth = build(occurred_on: 200, season: season.autumn)

      expect(birth.offspring).to eq(offspring)
      expect(birth.sire_id).to eq(sire_id)
      expect(birth.dam_id).to eq(dam_id)
      expect(birth.occurred_on).to eq(200)
      expect(birth.season).to eq(season.autumn)
    end

    it 'frozen で生成されること' do
      expect(build).to be_frozen
    end
  end

  describe '#to_s' do
    it '"種「名前」が誕生しました" の形で表されること' do
      expect(build.to_s).to eq('ライオン「シンバ」が誕生しました')
    end
  end
end
