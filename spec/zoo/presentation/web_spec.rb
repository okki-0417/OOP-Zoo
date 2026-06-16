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

  def post_json(path, payload = {})
    post path, payload.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  def patch_json(path, payload = {})
    patch path, payload.to_json, 'CONTENT_TYPE' => 'application/json'
  end

  def acquire(species: 'lion', name: 'レオ', sex: 'male')
    post_json '/animals', species: species, name: name, sex: sex
    body['id']
  end

  def build_enclosure(name: 'サバンナ', celsius: 30, capacity: 6)
    post_json '/enclosures', name: name, celsius: celsius, capacity: capacity
    body['id']
  end

  def hire_keeper(name: '田中', specialties: ['mammal'])
    post_json '/keepers', name: name, specialties: specialties
    body['id']
  end

  def hire_vet(name: '山田')
    post_json '/veterinarians', name: name
    body['id']
  end

  describe '参照データ' do
    it 'GET /species は種カタログを key 付きで返し、lion=ライオンを含むこと' do
      get '/species'

      expect(last_response.status).to eq(200)
      lion = body.find { |s| s['key'] == 'lion' }
      expect(lion).to include('name_ja' => 'ライオン', 'taxon_class' => '哺乳類', 'conservation_code' => 'VU')
    end

    it 'GET /foods は餌カタログを返し、horse_meat=馬肉(category=meat)を含むこと' do
      get '/foods'

      expect(last_response.status).to eq(200)
      expect(body.find { |f| f['key'] == 'horse_meat' }).to include('name_ja' => '馬肉', 'category' => 'meat')
    end

    it 'GET /taxon-classes は綱の一覧を返し、mammal=哺乳類を含むこと' do
      get '/taxon-classes'

      expect(last_response.status).to eq(200)
      expect(body).to include('key' => 'mammal', 'label' => '哺乳類')
    end
  end

  describe 'POST /animals' do
    it '種・名前・性別を JSON で渡すと201で動物プロフィールを返し Container に保存されること' do
      post_json '/animals', species: 'lion', name: 'レオ', sex: 'male'

      expect(last_response.status).to eq(201)
      expect(body).to include('name' => 'レオ', 'species' => 'ライオン', 'health' => 100, 'alive' => true)
      expect(container.animals.all.size).to eq(1)
    end

    it '未知の種は {error:{code:"ArgumentError"}} で400に翻訳されること' do
      post_json '/animals', species: 'dragon', name: 'X', sex: 'male'

      expect(last_response.status).to eq(400)
      expect(body['error']).to include('code' => 'ArgumentError')
      expect(body['error']['message']).to include('未知の種')
    end
  end

  describe 'GET /animals/:id' do
    it '存在する個体はプロフィールを返すこと' do
      id = acquire(name: 'レオ')

      get "/animals/#{id}"

      expect(last_response.status).to eq(200)
      expect(body).to include('id' => id, 'name' => 'レオ')
    end

    it '存在しない id は AnimalNotFound で404に翻訳されること' do
      get '/animals/missing'

      expect(last_response.status).to eq(404)
      expect(body['error']).to include('code' => 'AnimalNotFound')
    end
  end

  describe 'GET /animals' do
    it '取得した全個体のサマリ配列を返すこと' do
      acquire(name: 'レオ')
      acquire(name: 'シンバ')

      get '/animals'

      expect(last_response.status).to eq(200)
      expect(body.map { |a| a['name'] }).to contain_exactly('レオ', 'シンバ')
    end
  end

  describe 'PATCH /animals/:id/name' do
    it '新しい名前を渡すと改名され、更新後プロフィールを返すこと' do
      id = acquire(name: 'レオ')

      patch_json "/animals/#{id}/name", name: 'シンバ'

      expect(last_response.status).to eq(200)
      expect(body['name']).to eq('シンバ')
    end
  end

  describe 'POST /enclosures' do
    it '名前・気温・定員を渡すと201でエリアプロフィール(population=0)を返すこと' do
      post_json '/enclosures', name: 'サバンナ', celsius: 30, capacity: 6

      expect(last_response.status).to eq(201)
      expect(body).to include('name' => 'サバンナ', 'capacity' => 6, 'population' => 0)
    end
  end

  describe 'GET /enclosures/:id' do
    it '存在しない id は EnclosureNotFound で404に翻訳されること' do
      get '/enclosures/missing'

      expect(last_response.status).to eq(404)
      expect(body['error']).to include('code' => 'EnclosureNotFound')
    end
  end

  describe 'POST /enclosures/:id/occupants' do
    it '収容するとエリアの occupants にその個体が現れること' do
      enclosure_id = build_enclosure(capacity: 2)
      animal_id = acquire(name: 'レオ')

      post_json "/enclosures/#{enclosure_id}/occupants", animal_id: animal_id

      expect(last_response.status).to eq(200)
      expect(body['population']).to eq(1)
      expect(body['occupants'].map { |o| o['name'] }).to eq(['レオ'])
    end

    it '定員1のエリアに2頭目を収容すると CapacityExceeded で422に翻訳されること' do
      enclosure_id = build_enclosure(capacity: 1)
      first = acquire(name: '先住')
      post_json "/enclosures/#{enclosure_id}/occupants", animal_id: first
      second = acquire(name: 'はぐれ')

      post_json "/enclosures/#{enclosure_id}/occupants", animal_id: second

      expect(last_response.status).to eq(422)
      expect(body['error']).to include('code' => 'CapacityExceeded')
    end
  end

  describe 'DELETE /enclosures/:id/occupants/:animal_id' do
    it '退去させるとエリアの population が 0 に戻ること' do
      enclosure_id = build_enclosure(capacity: 2)
      animal_id = acquire
      post_json "/enclosures/#{enclosure_id}/occupants", animal_id: animal_id

      delete "/enclosures/#{enclosure_id}/occupants/#{animal_id}"

      expect(last_response.status).to eq(200)
      get "/enclosures/#{enclosure_id}"
      expect(body['population']).to eq(0)
    end
  end

  describe 'POST /animals/:id/transfer' do
    it '別エリアへ移送すると移送先の population が 1 になること' do
      from = build_enclosure(name: 'A', capacity: 2)
      to = build_enclosure(name: 'B', capacity: 2)
      animal_id = acquire
      post_json "/enclosures/#{from}/occupants", animal_id: animal_id

      post_json "/animals/#{animal_id}/transfer", enclosure_id: to

      expect(last_response.status).to eq(200)
      get "/enclosures/#{to}"
      expect(body['population']).to eq(1)
    end
  end

  describe 'POST /enclosures/:id/cleanings' do
    it '飼育員を指定して清掃すると200でエリアプロフィールを返すこと' do
      enclosure_id = build_enclosure
      keeper_id = hire_keeper

      post_json "/enclosures/#{enclosure_id}/cleanings", keeper_id: keeper_id

      expect(last_response.status).to eq(200)
      expect(body['cleanliness']).to eq(100)
    end
  end

  describe 'POST /animals/:id/feedings' do
    it '専門の飼育員が適した餌を与えると200で更新後プロフィールを返すこと' do
      keeper_id = hire_keeper(specialties: ['mammal'])
      animal_id = acquire(species: 'lion')

      post_json "/animals/#{animal_id}/feedings", keeper_id: keeper_id, food: 'horse_meat'

      expect(last_response.status).to eq(200)
      expect(body).to include('id' => animal_id)
      expect(body['hunger']).to be_a(Integer)
    end

    it '専門外の飼育員が給餌すると NotQualified で422に翻訳されること' do
      keeper_id = hire_keeper(specialties: ['bird'])
      animal_id = acquire(species: 'lion')

      post_json "/animals/#{animal_id}/feedings", keeper_id: keeper_id, food: 'horse_meat'

      expect(last_response.status).to eq(422)
      expect(body['error']).to include('code' => 'NotQualified')
    end
  end

  describe 'POST /animals/:id/examinations' do
    it '健康な個体を診察すると result="healthy" を返すこと' do
      vet_id = hire_vet
      animal_id = acquire

      post_json "/animals/#{animal_id}/examinations", veterinarian_id: vet_id

      expect(last_response.status).to eq(200)
      expect(body).to include('animal_id' => animal_id, 'result' => 'healthy')
    end
  end

  describe 'POST /animals/:id/treatments' do
    it '存在しない獣医を指定すると VeterinarianNotFound で404に翻訳されること' do
      animal_id = acquire

      post_json "/animals/#{animal_id}/treatments", veterinarian_id: 'missing'

      expect(last_response.status).to eq(404)
      expect(body['error']).to include('code' => 'VeterinarianNotFound')
    end
  end

  describe 'POST /breedings' do
    it '存在しない親を指定すると AnimalNotFound で404に翻訳されること' do
      enclosure_id = build_enclosure

      post_json '/breedings', sire_id: 'x', dam_id: 'y', enclosure_id: enclosure_id, name: '仔', sex: 'male'

      expect(last_response.status).to eq(404)
      expect(body['error']).to include('code' => 'AnimalNotFound')
    end
  end

  describe 'スタッフ' do
    it 'POST /keepers は専門綱つきで採用し、GET /keepers に現れること' do
      post_json '/keepers', name: '田中', specialties: %w[mammal bird]

      expect(last_response.status).to eq(201)
      expect(body).to include('name' => '田中', 'specialties' => '哺乳類・鳥類')

      get '/keepers'
      expect(body.map { |k| k['name'] }).to include('田中')
    end

    it 'POST /veterinarians は採用し、GET /veterinarians に現れること' do
      post_json '/veterinarians', name: '山田'

      expect(last_response.status).to eq(201)
      expect(body).to include('name' => '山田')

      get '/veterinarians'
      expect(body.map { |v| v['name'] }).to include('山田')
    end
  end

  describe '経営・運営' do
    it 'GET /deceased は死亡がなければ空配列を返すこと' do
      get '/deceased'

      expect(last_response.status).to eq(200)
      expect(body).to eq([])
    end

    it 'GET /threatened は絶滅危惧種を展示していればその種を返すこと' do
      enclosure_id = build_enclosure
      lion = acquire(species: 'lion')
      post_json "/enclosures/#{enclosure_id}/occupants", animal_id: lion

      get '/threatened'

      expect(last_response.status).to eq(200)
      expect(body.map { |s| s['name_ja'] }).to include('ライオン')
    end

    it 'PATCH /admission-fee は入園料を整数(円)で更新して返すこと' do
      patch_json '/admission-fee', fee: 3000

      expect(last_response.status).to eq(200)
      expect(body).to eq('admission_fee' => 3000)
    end

    it 'POST /visitors は来園を受け入れ収益を整数(円)で返すこと' do
      post_json '/visitors', count: 10

      expect(last_response.status).to eq(200)
      expect(body['revenue']).to eq(20_000)
    end

    it 'GET /report は園の統計を整数(円)の収益・残高つきで返すこと' do
      get '/report'

      expect(last_response.status).to eq(200)
      expect(body).to include('population', 'species_count', 'reputation')
      expect(body['revenue']).to be_a(Integer)
      expect(body['balance']).to be_a(Integer)
    end

    it 'POST /operate は1日運営し、来園・収支・残高を整数(円)で返すこと' do
      enclosure_id = build_enclosure
      zebra = acquire(species: 'grevys_zebra', name: 'シマオ')
      post_json "/enclosures/#{enclosure_id}/occupants", animal_id: zebra

      post '/operate'

      expect(last_response.status).to eq(200)
      expect(body).to include('visitors', 'deaths', 'reputation', 'bankrupt')
      expect(body['income']).to be_a(Integer)
      expect(body['balance']).to be_a(Integer)
    end

    it 'POST /run-days は指定日数を運営し推移サマリを返すこと' do
      post_json '/run-days', days: 3

      expect(last_response.status).to eq(200)
      expect(body).to include('days' => 3, 'total_deaths' => 0)
    end
  end
end
