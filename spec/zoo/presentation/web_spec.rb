# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require 'json'

RSpec.describe Zoo::Presentation::Web do
  include Rack::Test::Methods

  let(:container) { Zoo::Composition::Container.new }

  def app
    described_class
  end

  before { described_class.set(:container, container) }

  def body
    JSON.parse(last_response.body)
  end

  describe 'POST /animals' do
    it '種・名前・性別を渡すと201で個体を作り、同じ Container に保存されること' do
      post '/animals', species: 'lion', name: 'レオ', sex: 'male'

      expect(last_response.status).to eq(201)
      expect(body['name']).to eq('レオ')
      expect(container.animals.all.size).to eq(1)
    end

    it '未知の種は ArgumentError → 400 に翻訳されること' do
      post '/animals', species: 'dragon', name: 'X', sex: 'male'

      expect(last_response.status).to eq(400)
      expect(body['error']).to include('未知の種')
    end
  end

  describe 'GET /animals/:id' do
    it '存在しない id は AnimalNotFound → 404 に翻訳されること' do
      get '/animals/missing'

      expect(last_response.status).to eq(404)
    end
  end

  describe 'POST /enclosures/:id/occupants' do
    it '定員超過は CapacityExceeded → 422 に翻訳されること' do
      post '/enclosures', name: '小屋', celsius: '28', capacity: '1'
      enclosure_id = body['id']
      post '/animals', species: 'lion', name: '先住', sex: 'male'
      post "/enclosures/#{enclosure_id}/occupants", animal_id: body['id']
      post '/animals', species: 'lion', name: 'はぐれ', sex: 'male'

      post "/enclosures/#{enclosure_id}/occupants", animal_id: body['id']

      expect(last_response.status).to eq(422)
    end
  end

  describe 'POST /operate' do
    it '1日運営すると来園・収支・評判・残高を JSON で返すこと' do
      post '/enclosures', name: 'サバンナ', celsius: '30', capacity: '6'
      enclosure_id = body['id']
      post '/animals', species: 'grevys_zebra', name: 'シマオ', sex: 'male'
      post "/enclosures/#{enclosure_id}/occupants", animal_id: body['id']

      post '/operate'

      expect(last_response.status).to eq(200)
      expect(body).to include('visitors', 'income', 'cost', 'reputation', 'balance')
    end
  end
end
