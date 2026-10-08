# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::OperateDay do
  describe 'operateDay' do
    subject(:response) { OopZooSchema.execute('mutation { operateDay { day } }').to_h }

    let!(:zoo) { create(:zoo) }

    it 'day=1 の営業記録を返すこと' do
      expect(response).to eq('data' => { 'operateDay' => { 'day' => 1 } })
    end

    it '営業記録を保存し、園を1日進めること' do
      response

      expect(Operating.sole.day).to eq(1)
      expect(zoo.reload.day).to eq(1)
    end
  end
end
