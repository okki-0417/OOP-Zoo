# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Query do
  it 'animals・enclosures・keepers・veterinarians は保存順(id 昇順)に返すこと' do
    leo = create(:animal, name: 'レオ')
    nala = create(:animal, :female, name: 'ナラ')
    hill = create(:enclosure, name: '丘')
    pond = create(:enclosure, name: '池')
    keeper = create(:keeper)
    vet = create(:veterinarian)

    expect(run_graphql_field('Query.animals', nil)).to eq([leo, nala])
    expect(run_graphql_field('Query.enclosures', nil)).to eq([hill, pond])
    expect(run_graphql_field('Query.keepers', nil)).to eq([keeper])
    expect(run_graphql_field('Query.veterinarians', nil)).to eq([vet])
  end

  it 'animal(id:)・enclosure(id:) は保存した id でそのレコードを、存在しない id "0" で nil を返すこと' do
    leo = create(:animal)
    hill = create(:enclosure)

    expect(run_graphql_field('Query.animal', nil, arguments: { id: leo.id.to_s })).to eq(leo)
    expect(run_graphql_field('Query.animal', nil, arguments: { id: '0' })).to be_nil
    expect(run_graphql_field('Query.enclosure', nil, arguments: { id: hill.id.to_s })).to eq(hill)
    expect(run_graphql_field('Query.enclosure', nil, arguments: { id: '0' })).to be_nil
  end

  it 'zoo は園がまだなければ既定の "OOP動物園" を作って返すこと' do
    expect(run_graphql_field('Query.zoo', nil)).to have_attributes(name: 'OOP動物園', persisted?: true)
  end

  it 'operatings は day の昇順に返すこと' do
    second, first = [2, 1].map do |day|
      Operating.create!(day:, visitors: 0, income: Money.zero, cost: Money.zero, deaths: 0, balance: Balance.zero,
                        reputation: 50, total_visitors: 0, total_revenue: Money.zero, expenses: [])
    end

    expect(run_graphql_field('Query.operatings', nil)).to eq([first, second])
  end

  it 'alerts は飼育員のいない園でライオンを担当のいないエリアに収容すると [no_keeper, unassigned] の警告を返すこと' do
    create(:zoo)
    create(:animal, enclosure: create(:enclosure))

    expect(run_graphql_field('Query.alerts', nil).pluck(:kind)).to eq(%i[no_keeper unassigned])
  end

  it 'species・foods・taxonClasses はカタログの全件(先頭は哺乳類)を返すこと' do
    expect(run_graphql_field('Query.species', nil)).to eq(SpeciesCatalog.all)
    expect(run_graphql_field('Query.foods', nil)).to eq(FoodCatalog.all)
    expect(run_graphql_field('Query.taxonClasses', nil).first).to eq(TaxonClass.mammal)
  end
end
