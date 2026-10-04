# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Enclosures', type: :request do
  describe 'POST /api/v1/enclosures' do
    it '名前・気温・定員を指定してエンクロージャを作成すること' do
      post '/api/v1/enclosures', params: { name: 'サバンナ舎', celsius: 25, capacity: 3 }

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body['name']).to eq('サバンナ舎')
      expect(body['capacity']).to eq(3)
      expect(body['population']).to eq(0)
    end

    it '定員が0以下だと422になること' do
      post '/api/v1/enclosures', params: { name: '小屋', celsius: 25, capacity: 0 }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'GET /api/v1/enclosures/:id' do
    it '在室動物のサマリを含めて返すこと' do
      enclosure = Enclosure.build(name: 'サバンナ舎', temperature: Temperature.celsius(25), capacity: 3)
      animal = Animal.acquire(species_key: :lion, name: 'Leo', sex: 'male', max_health: 100)
      Housing.house(animal: animal, enclosure: enclosure, occupancy: Occupancy.of(enclosure))

      get "/api/v1/enclosures/#{enclosure.id}"

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['population']).to eq(1)
      expect(body['occupants'].first['name']).to eq('Leo')
    end
  end
end
