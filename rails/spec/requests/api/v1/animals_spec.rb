# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Animals', type: :request do
  describe 'POST /api/v1/animals' do
    it '種・名前・性別・最大体力を指定して個体を作成すること' do
      post '/api/v1/animals', params: { species: 'lion', name: 'Leo', sex: 'male', max_health: 100 }

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body['name']).to eq('Leo')
      expect(body['species']).to eq('ライオン')
      expect(body['alive']).to be(true)
    end

    it '未知の種を指定すると400になること' do
      post '/api/v1/animals', params: { species: 'dragon', name: 'X', sex: 'male', max_health: 100 }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'GET /api/v1/animals' do
    it '一覧をサマリ形式で返すこと' do
      Animal.acquire(species_key: :lion, name: 'Leo', sex: 'male', max_health: 100)

      get '/api/v1/animals'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.first.keys).to contain_exactly(
        'id', 'name', 'species', 'alive', 'health', 'max_health', 'ailing'
      )
    end
  end

  describe 'GET /api/v1/animals/:id' do
    it '存在しないIDは404になること' do
      get '/api/v1/animals/999'

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/v1/animals/:id/name' do
    it '改名できること' do
      animal = Animal.acquire(species_key: :lion, name: 'Leo', sex: 'male', max_health: 100)

      patch "/api/v1/animals/#{animal.id}/name", params: { name: 'Leo2' }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['name']).to eq('Leo2')
    end
  end

  describe 'POST /api/v1/animals/:id/transfer' do
    it '収容先を切り替えられること' do
      from = Enclosure.build(name: '第一舎', temperature: Temperature.celsius(25), capacity: 2)
      to = Enclosure.build(name: '第二舎', temperature: Temperature.celsius(25), capacity: 2)
      animal = Animal.acquire(species_key: :lion, name: 'Leo', sex: 'male', max_health: 100)
      Housing.house(animal: animal, enclosure: from, occupancy: Occupancy.of(from))

      post "/api/v1/animals/#{animal.id}/transfer", params: { enclosure_id: to.id }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['enclosure_id']).to eq(to.id)
      expect(Housing.occupants_of(from)).to be_empty
    end
  end
end
