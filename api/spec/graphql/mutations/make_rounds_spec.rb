# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::MakeRounds do
  describe 'makeRounds(keeperId:)' do
    subject(:response) do
      OopZooSchema.execute(
        %(mutation { makeRounds(keeperId: "#{keeper.id}") { keeper { name } reports { enclosure { name } fed { name } } } }),
        context: { current_zoo: zoo }
      ).to_h
    end

    let(:zoo) { create(:zoo) }
    let(:hill) { create(:enclosure, zoo:, name: '丘') }
    let(:keeper) { create(:keeper, zoo:, name: '田中', enclosures: [hill]) }
    let!(:lion) { create(:animal, zoo:, name: 'レオ', enclosure: hill) }

    it '田中と、丘でレオに給餌した報告を返すこと' do
      expect(response).to eq(
        'data' => { 'makeRounds' => {
          'keeper' => { 'name' => '田中' }, 'reports' => [{ 'enclosure' => { 'name' => '丘' }, 'fed' => [{ 'name' => 'レオ' }] }]
        } }
      )
    end

    it 'レオの食事を保存すること' do
      response

      expect(lion.reload).to be_fed_today
    end
  end
end
