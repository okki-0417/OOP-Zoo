# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Types::Query do
  let(:zoo) { create(:zoo) }
  let(:context) { { current_zoo: zoo } }

  describe 'animals' do
    let!(:leo) { create(:animal, name: 'レオ', zoo:) }
    let!(:nala) { create(:animal, :female, name: 'ナラ', zoo:) }

    before { create(:animal, name: 'よその動物') }

    it 'ほかの園の動物を含めず、保存順(id 昇順)の [レオ, ナラ] を返すこと' do
      expect(run_graphql_field('Query.animals', nil, context:)).to eq([leo, nala])
    end
  end

  describe 'animal(id:)' do
    subject(:animal) { run_graphql_field('Query.animal', nil, arguments: { id: }, context:) }

    let(:leo) { create(:animal, zoo:) }
    let(:id) { leo.id.to_s }

    it '保存した id でその動物を返すこと' do
      expect(animal).to eq(leo)
    end

    context '存在しない id "0" を渡したとき' do
      let(:id) { '0' }

      it 'nil を返すこと' do
        expect(animal).to be_nil
      end
    end

    context 'ほかの園の動物の id を渡したとき' do
      let(:id) { create(:animal).id.to_s }

      it 'nil を返すこと' do
        expect(animal).to be_nil
      end
    end
  end

  describe 'enclosures' do
    let!(:hill) { create(:enclosure, name: '丘', zoo:) }
    let!(:pond) { create(:enclosure, name: '池', zoo:) }

    before { create(:enclosure, name: 'よそのエリア') }

    it 'ほかの園のエリアを含めず、保存順(id 昇順)の [丘, 池] を返すこと' do
      expect(run_graphql_field('Query.enclosures', nil, context:)).to eq([hill, pond])
    end
  end

  describe 'enclosure(id:)' do
    subject(:enclosure) { run_graphql_field('Query.enclosure', nil, arguments: { id: }, context:) }

    let(:hill) { create(:enclosure, zoo:) }
    let(:id) { hill.id.to_s }

    it '保存した id でそのエリアを返すこと' do
      expect(enclosure).to eq(hill)
    end

    context '存在しない id "0" を渡したとき' do
      let(:id) { '0' }

      it 'nil を返すこと' do
        expect(enclosure).to be_nil
      end
    end

    context 'ほかの園のエリアの id を渡したとき' do
      let(:id) { create(:enclosure).id.to_s }

      it 'nil を返すこと' do
        expect(enclosure).to be_nil
      end
    end
  end

  describe 'keepers' do
    let!(:keeper) { create(:keeper, zoo:) }

    before { create(:keeper) }

    it 'ほかの園の飼育員を含めず、保存した飼育員を返すこと' do
      expect(run_graphql_field('Query.keepers', nil, context:)).to eq([keeper])
    end
  end

  describe 'veterinarians' do
    let!(:vet) { create(:veterinarian, zoo:) }

    before { create(:veterinarian) }

    it 'ほかの園の獣医を含めず、保存した獣医を返すこと' do
      expect(run_graphql_field('Query.veterinarians', nil, context:)).to eq([vet])
    end
  end

  describe 'zoo' do
    it 'context の current_zoo を返すこと' do
      expect(run_graphql_field('Query.zoo', nil, context:)).to eq(zoo)
    end
  end

  describe 'operatings' do
    let(:attributes) do
      { visitors: 0, income: Money.zero, cost: Money.zero, deaths: 0, balance: Balance.zero,
        reputation: 50, total_visitors: 0, total_revenue: Money.zero, expenses: [] }
    end
    let!(:second) { Operating.create!(zoo:, day: 2, **attributes) }
    let!(:first) { Operating.create!(zoo:, day: 1, **attributes) }

    before { Operating.create!(zoo: create(:zoo), day: 1, **attributes) }

    it 'ほかの園の記録を含めず、2日目→1日目の順に保存しても day の昇順 [1日目, 2日目] で返すこと' do
      expect(run_graphql_field('Query.operatings', nil, context:)).to eq([first, second])
    end
  end

  describe 'alerts' do
    before { create(:animal, zoo:, enclosure: create(:enclosure, zoo:)) }

    context '飼育員のいない園で、担当のいないエリアにライオンを収容しているとき' do
      it '[no_keeper, unassigned] の警告を返すこと' do
        expect(run_graphql_field('Query.alerts', nil, context:).pluck(:kind)).to eq(%i[no_keeper unassigned])
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
