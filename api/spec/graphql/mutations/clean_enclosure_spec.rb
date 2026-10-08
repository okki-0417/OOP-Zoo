# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CleanEnclosure do
  describe 'cleanEnclosure(enclosureId:, keeperId:)' do
    subject(:response) do
      OopZooSchema.execute(
        %(mutation { cleanEnclosure(enclosureId: "#{hill.id}", keeperId: "#{keeper.id}") { name cleanliness } }),
        context: { current_zoo: zoo }
      ).to_h
    end

    let(:zoo) { create(:zoo) }
    let(:hill) { create(:enclosure, zoo:, name: '丘').soil(50).tap(&:save!) }
    let(:keeper) { create(:keeper, zoo:) }

    it '清潔度50の丘を清掃して cleanliness=100 で返すこと' do
      expect(response).to eq('data' => { 'cleanEnclosure' => { 'name' => '丘', 'cleanliness' => 100 } })
    end

    it '丘の清潔度と飼育員の勤務時間を保存すること' do
      response

      expect(hill.reload.cleanliness_level).to eq(100)
      expect(keeper.reload.worked_minutes).to eq(Cleaning::WORK_MINUTES)
    end
  end
end
