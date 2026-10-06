# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'POST /graphql', type: :request do
  let(:log) { StringIO.new }

  around do |example|
    original_container = Rails.configuration.x.zoo_container
    original_logger = Rails.logger
    Rails.configuration.x.zoo_container = Zoo::Composition::Container.new
    Rails.logger = Logger.new(log)
    example.run
  ensure
    Rails.configuration.x.zoo_container = original_container
    Rails.logger = original_logger
  end

  def graphql(query, variables = {})
    post '/graphql', params: { query:, variables: }.to_json, headers: { 'CONTENT_TYPE' => 'application/json' }
    response.parsed_body
  end

  it 'acquireAnimal → addEnclosure → houseAnimal と送ると、houseAnimal の応答に occupants ["レオ"] と occupancy.full=false が返ること' do
    animal_id = graphql('mutation { acquireAnimal(speciesCode: "lion", name: "レオ", sex: MALE) { id } }')
                .dig('data', 'acquireAnimal', 'id')
    enclosure_id = graphql('mutation { addEnclosure(name: "ライオンの丘", celsius: 28, capacity: 4) { id } }')
                   .dig('data', 'addEnclosure', 'id')

    body = graphql(
      'mutation($enclosureId: ID!, $animalId: ID!) { ' \
      'houseAnimal(enclosureId: $enclosureId, animalId: $animalId) { name occupants { name } occupancy { full } } }',
      { enclosureId: enclosure_id, animalId: animal_id }
    )

    expect(response).to have_http_status(:ok)
    expect(body).to eq(
      'data' => {
        'houseAnimal' => { 'name' => 'ライオンの丘', 'occupants' => [{ 'name' => 'レオ' }], 'occupancy' => { 'full' => false } }
      }
    )
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
