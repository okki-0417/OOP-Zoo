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

  def graphql(query, variables = {})
    post '/graphql', { query:, variables: }.to_json, 'CONTENT_TYPE' => 'application/json'
    JSON.parse(last_response.body)
  end

  it 'acquireAnimal → addEnclosure → houseAnimal と送ると、houseAnimal の応答に occupants ["レオ"] と occupancy.full=false が返ること' do
    animal_id = graphql('mutation { acquireAnimal(speciesCode: "lion", name: "レオ", sex: "male") { id } }')
                .dig('data', 'acquireAnimal', 'id')
    enclosure_id = graphql('mutation { addEnclosure(name: "ライオンの丘", celsius: 28, capacity: 4) { id } }')
                   .dig('data', 'addEnclosure', 'id')

    response = graphql(
      'mutation($enclosureId: ID!, $animalId: ID!) { ' \
      'houseAnimal(enclosureId: $enclosureId, animalId: $animalId) { name occupants { name } occupancy { full } } }',
      { enclosureId: enclosure_id, animalId: animal_id }
    )

    expect(last_response.status).to eq(200)
    expect(response).to eq(
      'data' => {
        'houseAnimal' => { 'name' => 'ライオンの丘', 'occupants' => [{ 'name' => 'レオ' }], 'occupancy' => { 'full' => false } }
      }
    )
  end

  it "未知の種 dragon で acquireAnimal を送ると、200 で data が null・errors[0].extensions.code が 'SpeciesNotFound' になること" do
    response = graphql('mutation { acquireAnimal(speciesCode: "dragon", name: "X", sex: "male") { id } }')

    expect(last_response.status).to eq(200)
    expect(response['data']).to be_nil
    expect(response['errors'].first['extensions']).to eq('code' => 'SpeciesNotFound')
  end

  it 'OPTIONS /graphql は 200 で Access-Control-Allow-Origin: * を返すこと' do
    options '/graphql'

    expect(last_response.status).to eq(200)
    expect(last_response.headers['Access-Control-Allow-Origin']).to eq('*')
  end
end
