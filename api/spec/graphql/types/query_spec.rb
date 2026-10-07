# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Query do
  describe 'animals' do
    let!(:leo) { create(:animal, name: 'レオ') }
    let!(:nala) { create(:animal, :female, name: 'ナラ') }

    it '保存順(id 昇順)の [レオ, ナラ] を返すこと' do
      expect(run_graphql_field('Query.animals', nil)).to eq([leo, nala])
    end
  end

  describe 'animal(id:)' do
    let!(:leo) { create(:animal) }

    it '保存した id でその動物を返すこと' do
      expect(run_graphql_field('Query.animal', nil, arguments: { id: leo.id.to_s })).to eq(leo)
    end

    context '存在しない id "0" を渡したとき' do
      it 'nil を返すこと' do
        expect(run_graphql_field('Query.animal', nil, arguments: { id: '0' })).to be_nil
      end
    end
  end

  describe 'enclosures' do
    let!(:hill) { create(:enclosure, name: '丘') }
    let!(:pond) { create(:enclosure, name: '池') }

    it '保存順(id 昇順)の [丘, 池] を返すこと' do
      expect(run_graphql_field('Query.enclosures', nil)).to eq([hill, pond])
    end
  end

  describe 'enclosure(id:)' do
    let!(:hill) { create(:enclosure) }

    it '保存した id でそのエリアを返すこと' do
      expect(run_graphql_field('Query.enclosure', nil, arguments: { id: hill.id.to_s })).to eq(hill)
    end

    context '存在しない id "0" を渡したとき' do
      it 'nil を返すこと' do
        expect(run_graphql_field('Query.enclosure', nil, arguments: { id: '0' })).to be_nil
      end
    end
  end

  describe 'keepers' do
    let!(:keeper) { create(:keeper) }

    it '保存した飼育員を返すこと' do
      expect(run_graphql_field('Query.keepers', nil)).to eq([keeper])
    end
  end

  describe 'veterinarians' do
    let!(:vet) { create(:veterinarian) }

    it '保存した獣医を返すこと' do
      expect(run_graphql_field('Query.veterinarians', nil)).to eq([vet])
    end
  end

  describe 'zoo' do
    context '園がまだないとき' do
      it '既定の "OOP動物園" を作って返すこと' do
        expect(run_graphql_field('Query.zoo', nil)).to have_attributes(name: 'OOP動物園', persisted?: true)
      end
    end
  end

  describe 'operatings' do
    let(:attributes) do
      { visitors: 0, income: Money.zero, cost: Money.zero, deaths: 0, balance: Balance.zero,
        reputation: 50, total_visitors: 0, total_revenue: Money.zero, expenses: [] }
    end
    let!(:second) { Operating.create!(day: 2, **attributes) }
    let!(:first) { Operating.create!(day: 1, **attributes) }

    it '2日目→1日目の順に保存しても day の昇順 [1日目, 2日目] で返すこと' do
      expect(run_graphql_field('Query.operatings', nil)).to eq([first, second])
    end
  end

  describe 'alerts' do
    before do
      create(:zoo)
      create(:animal, enclosure: create(:enclosure))
    end

    context '飼育員のいない園で、担当のいないエリアにライオンを収容しているとき' do
      it '[no_keeper, unassigned] の警告を返すこと' do
        expect(run_graphql_field('Query.alerts', nil).pluck(:kind)).to eq(%i[no_keeper unassigned])
      end
    end
  end

  describe 'species' do
    it 'カタログの全種を返すこと' do
      expect(run_graphql_field('Query.species', nil)).to eq(SpeciesCatalog.all)
    end
  end

  describe 'foods' do
    it 'カタログの全餌を返すこと' do
      expect(run_graphql_field('Query.foods', nil)).to eq(FoodCatalog.all)
    end
  end

  describe 'taxonClasses' do
    it '先頭が哺乳類の綱の一覧を返すこと' do
      expect(run_graphql_field('Query.taxonClasses', nil).first).to eq(TaxonClass.mammal)
    end
  end
end
