# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::RunDays do
  describe 'runDays(days:)' do
    subject(:response) { OopZooSchema.execute(%(mutation { runDays(days: #{days}) { days totalDeaths } }), context: { current_zoo: zoo }).to_h }

    let(:zoo) { create(:zoo) }

    context 'days が3のとき' do
      let(:days) { 3 }

      it 'days=3・totalDeaths=0 を返すこと' do
        expect(response).to eq('data' => { 'runDays' => { 'days' => 3, 'totalDeaths' => 0 } })
      end

      it '3日分の営業記録を保存すること' do
        response

        expect(zoo.operatings.order(:day).pluck(:day)).to eq([1, 2, 3])
      end
    end

    context 'days が0のとき' do
      let(:days) { 0 }

      it "data を null にし、errors[0].message を '日数は1以上でなければなりません' にして、営業記録を保存しないこと" do
        expect(response['data']).to be_nil
        expect(response['errors'].first['message']).to eq('日数は1以上でなければなりません')
        expect(Operating.count).to eq(0)
      end
    end
  end
end
