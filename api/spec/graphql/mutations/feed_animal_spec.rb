# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::FeedAnimal do
  describe 'feedAnimal(animalId:, keeperId:, foodCode:)' do
    subject(:response) do
      OopZooSchema.execute(
        %(mutation { feedAnimal(animalId: "#{lion.id}", keeperId: "#{keeper.id}", foodCode: "#{food_code}") { name fedToday } })
      ).to_h
    end

    let(:lion) { create(:animal, name: 'レオ') }
    let(:keeper) { create(:keeper) }
    let(:food_code) { 'horse_meat' }

    context 'foodCode が "horse_meat" のとき' do
      it 'fedToday=true のレオを返すこと' do
        expect(response).to eq('data' => { 'feedAnimal' => { 'name' => 'レオ', 'fedToday' => true } })
      end

      it 'レオの食事と飼育員の勤務時間を保存すること' do
        response

        expect(lion.reload).to be_fed_today
        expect(keeper.reload.worked_minutes).to eq(Feeding::WORK_MINUTES)
      end
    end

    context 'foodCode が未知の "cake" のとき' do
      let(:food_code) { 'cake' }

      it "extensions.code を 'FoodNotFound' にすること" do
        expect(response['errors'].first['extensions']).to eq('code' => 'FoodNotFound')
      end
    end
  end
end
