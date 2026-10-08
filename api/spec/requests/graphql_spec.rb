# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'POST /graphql', type: :request do
  subject(:body) do
    post '/graphql', params: { query:, variables: }.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    response.parsed_body
  end

  let(:variables) { {} }

  context 'query { enclosures { name } } を送ったとき' do
    let(:query) { '{ enclosures { name } }' }

    before { create(:enclosure, name: '丘') }

    it '200 で data.enclosures に保存済みのエリア名 "丘" を返すこと' do
      expect(body).to eq('data' => { 'enclosures' => [{ 'name' => '丘' }] })
      expect(response).to have_http_status(:ok)
    end
  end

  context '未知の種 dragon で acquireAnimal を送ったとき' do
    let(:query) { 'mutation { acquireAnimal(speciesCode: "dragon", name: "X", sex: MALE) { id } }' }

    it "200 で data を null に、errors[0].extensions.code を 'SpeciesNotFound' にすること" do
      expect(body['data']).to be_nil
      expect(body['errors'].first['extensions']).to eq('code' => 'SpeciesNotFound')
      expect(response).to have_http_status(:ok)
    end
  end
end

RSpec.describe 'OPTIONS /graphql', type: :request do
  context 'Origin 付きのプリフライトを送ったとき' do
    before do
      process :options, '/graphql', headers: {
        'Origin' => 'http://localhost:5173',
        'Access-Control-Request-Method' => 'POST',
        'Access-Control-Request-Headers' => 'Content-Type'
      }
    end

    it '200 で Access-Control-Allow-Origin: * を返すこと' do
      expect(response).to have_http_status(:ok)
      expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
    end
  end
end
