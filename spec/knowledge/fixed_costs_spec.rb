# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '固定費と休園' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog

  def savanna
    Zoo::Domain::Husbandry::Enclosure.new(
      name: 'サバンナ', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
    )
  end

  describe '固定費は収入に依存しない' do
    it '在園個体がいれば、来園者のいない休園日でも運営費が発生すること' do
      daily = Zoo::Domain::Operations::OperatingCost.daily(
        enclosures: [savanna], staff: 1, species: [catalog.lion]
      )
      expect(daily.yen).to be > 0
    end

    it '運営費は来園者数ではなく在園頭数で増えること(飼料費)' do
      one = Zoo::Domain::Operations::OperatingCost.daily(
        enclosures: [savanna], staff: 1, species: [catalog.lion]
      )
      two = Zoo::Domain::Operations::OperatingCost.daily(
        enclosures: [savanna], staff: 1, species: [catalog.lion, catalog.african_elephant]
      )
      expect(two.yen).to be > one.yen
    end

    it '在園個体がいなくても、エリアと職員の維持費は発生すること' do
      daily = Zoo::Domain::Operations::OperatingCost.daily(
        enclosures: [savanna], staff: 1, species: []
      )
      expect(daily.yen).to be > 0
    end
  end
end
