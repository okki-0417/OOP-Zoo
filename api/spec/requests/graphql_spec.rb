# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'POST /graphql', type: :request do
  let(:log) { StringIO.new }

  around do |example|
    original_logger = Rails.logger
    Rails.logger = Logger.new(log)
    example.run
  ensure
    Rails.logger = original_logger
  end

  def graphql(query, variables = {})
    post '/graphql', params: { query:, variables: }.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    response.parsed_body
  end

  it 'POST /graphql に query { enclosures { name } } と送ると、200 で data.enclosures に保存済みのエリア名 "丘" が返ること' do
    create(:enclosure, name: '丘')

    body = graphql('{ enclosures { name } }')

    expect(response).to have_http_status(:ok)
    expect(body).to eq('data' => { 'enclosures' => [{ 'name' => '丘' }] })
  end

  it "未知の種 dragon で acquireAnimal を送ると、200 で data が null・errors[0].extensions.code が 'SpeciesNotFound' になること" do
    body = graphql('mutation { acquireAnimal(speciesCode: "dragon", name: "X", sex: MALE) { id } }')

    expect(response).to have_http_status(:ok)
    expect(body['data']).to be_nil
    expect(body['errors'].first['extensions']).to eq('code' => 'SpeciesNotFound')
  end

  it 'Origin 付きの OPTIONS /graphql(プリフライト) は Access-Control-Allow-Origin: * を返すこと' do
    process :options, '/graphql', headers: {
      'Origin' => 'http://localhost:5173',
      'Access-Control-Request-Method' => 'POST',
      'Access-Control-Request-Headers' => 'Content-Type'
    }

    expect(response).to have_http_status(:ok)
    expect(response.headers['Access-Control-Allow-Origin']).to eq('*')
  end

  it 'mutation AcquireAnimal($name) を送ると、操作の種類と名前・variables・1行に詰めたクエリ・エラーコードをログに出すこと' do
    graphql(
      "mutation AcquireAnimal($name: String!) {\n  acquireAnimal(speciesCode: \"dragon\", name: $name, sex: MALE) { id }\n}",
      { name: 'X' }
    )

    expect(log.string).to include('GraphQL mutation AcquireAnimal')
    expect(log.string).to include('Variables: {"name":"X"}')
    expect(log.string).to include(
      'Query: mutation AcquireAnimal($name: String!) { acquireAnimal(speciesCode: "dragon", name: $name, sex: MALE) { id } }'
    )
    expect(log.string).to match(/Completed in \d+ms \(errors: SpeciesNotFound\)/)
  end
end
