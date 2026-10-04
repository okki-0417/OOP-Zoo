# frozen_string_literal: true

require 'spec_helper'
require 'rack/test'
require 'json'

RSpec.describe 'GET /api/v1 最小ゲームループ' do
  include Rack::Test::Methods

  let(:container) { Zoo::Composition::Container.new }

  def app
    Zoo::Presentation::Web
  end

  before { Zoo::Presentation::Web.set(:container, container) }

  def body
    JSON.parse(last_response.body)
  end

  def post_json(path, payload = {})
    post path, payload.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  describe 'GET /api/v1/species' do
    it '種カタログを返し lion=ライオンを含むこと' do
      get '/api/v1/species'

      expect(last_response.status).to eq(200)
      expect(body.find { |s| s['key'] == 'lion' }).to include('name_ja' => 'ライオン')
    end
  end

  describe 'GET /api/v1/taxon-classes' do
    it '綱の一覧を返し mammal=哺乳類を含むこと' do
      get '/api/v1/taxon-classes'

      expect(last_response.status).to eq(200)
      expect(body).to include('key' => 'mammal', 'label' => '哺乳類')
    end
  end

  describe 'GET /api/v1/report' do
    it '園の統計(population/reputation/balance)を返すこと' do
      get '/api/v1/report'

      expect(last_response.status).to eq(200)
      expect(body).to include('population', 'species_count', 'reputation', 'balance')
    end
  end

  describe 'POST /api/v1/enclosures' do
    it '名前・気温・定員を渡すと201でエリアプロフィールを返すこと' do
      post_json '/api/v1/enclosures', name: 'サバンナ', celsius: 30, capacity: 6

      expect(last_response.status).to eq(201)
      expect(body).to include('name' => 'サバンナ', 'capacity' => 6, 'population' => 0)
    end
  end

  describe 'GET /api/v1/enclosures' do
    it '登録済みエリアの一覧を返すこと' do
      post_json '/api/v1/enclosures', name: 'サバンナ', celsius: 30, capacity: 6

      get '/api/v1/enclosures'

      expect(last_response.status).to eq(200)
      expect(body.map { |e| e['name'] }).to include('サバンナ')
    end
  end

  describe 'POST /api/v1/animals' do
    it 'POST /api/v1/animals は廃止されており404を返すこと' do
      post_json '/api/v1/animals', species: 'lion', name: 'レオ', sex: 'male'

      expect(last_response.status).to eq(404)
    end
  end

  describe 'GET /api/v1/animals' do
    it '取得した動物の一覧を返すこと' do
      post_json '/animals', species: 'lion', name: 'レオ', sex: 'male'

      get '/api/v1/animals'

      expect(last_response.status).to eq(200)
      expect(body.map { |a| a['name'] }).to include('レオ')
    end
  end

  describe 'POST /api/v1/enclosures/:id/occupants' do
    it '動物をエリアに収容すると occupants にその個体が現れること' do
      post_json '/api/v1/enclosures', name: 'サバンナ', celsius: 30, capacity: 6
      enclosure_id = body['id']
      post_json '/animals', species: 'lion', name: 'レオ', sex: 'male'
      animal_id = body['id']

      post_json "/api/v1/enclosures/#{enclosure_id}/occupants", animal_id: animal_id

      expect(last_response.status).to eq(200)
      expect(body['population']).to eq(1)
      expect(body['occupants'].map { |o| o['name'] }).to eq(['レオ'])
    end
  end

  describe 'POST /api/v1/keepers' do
    it '名前と担当綱を渡すと201で飼育員を返すこと' do
      post_json '/api/v1/keepers', name: '田中', specialties: ['mammal']

      expect(last_response.status).to eq(201)
      expect(body).to include('name' => '田中')
    end
  end

  describe 'POST /api/v1/operate' do
    it '1日運営し visitors/income/balance/reputation を返すこと' do
      post_json '/api/v1/enclosures', name: 'サバンナ', celsius: 30, capacity: 6
      enclosure_id = body['id']
      post_json '/animals', species: 'grevys_zebra', name: 'シマオ', sex: 'male'
      animal_id = body['id']
      post_json "/api/v1/enclosures/#{enclosure_id}/occupants", animal_id: animal_id

      post '/api/v1/operate'

      expect(last_response.status).to eq(200)
      expect(body).to include('visitors', 'income', 'balance', 'reputation', 'bankrupt')
    end
  end

  describe '最小ゲームループ e2e' do
    it '檻→動物→収容→飼育員→運営→レポートの一周が成立すること' do
      post_json '/api/v1/enclosures', name: 'サバンナ', celsius: 30, capacity: 6
      enclosure_id = body['id']

      post_json '/animals', species: 'lion', name: 'レオ', sex: 'male'
      animal_id = body['id']

      post_json "/api/v1/enclosures/#{enclosure_id}/occupants", animal_id: animal_id
      expect(last_response.status).to eq(200)

      post_json '/api/v1/keepers', name: '田中', specialties: ['mammal']
      expect(last_response.status).to eq(201)

      post '/api/v1/operate'
      expect(last_response.status).to eq(200)
      expect(body['bankrupt']).to eq(false)

      get '/api/v1/report'
      expect(last_response.status).to eq(200)
      expect(body['population']).to eq(1)
    end
  end
end
