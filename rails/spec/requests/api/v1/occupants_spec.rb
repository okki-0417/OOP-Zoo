# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Occupants', type: :request do
  let(:enclosure) { Enclosure.build(name: 'サバンナ舎', temperature: Temperature.celsius(25), capacity: 1) }
  let(:animal) { Animal.acquire(species_key: :lion, name: 'Leo', sex: 'male', max_health: 100) }

  describe 'POST /api/v1/enclosures/:enclosure_id/occupants' do
    it '収容できること' do
      post "/api/v1/enclosures/#{enclosure.id}/occupants", params: { animal_id: animal.id }

      expect(response).to have_http_status(:created)
      expect(response.parsed_body['population']).to eq(1)
    end

    it '定員超過なら422を返すこと' do
      Housing.house(animal: animal, enclosure: enclosure, occupancy: Occupancy.of(enclosure))
      newcomer = Animal.acquire(species_key: :lion, name: 'Rex', sex: 'male', max_health: 100)

      post "/api/v1/enclosures/#{enclosure.id}/occupants", params: { animal_id: newcomer.id }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['error']['code']).to eq('HousingNotAllowed')
    end
  end

  describe 'DELETE /api/v1/enclosures/:enclosure_id/occupants/:animal_id' do
    it '解放できること' do
      Housing.house(animal: animal, enclosure: enclosure, occupancy: Occupancy.of(enclosure))

      delete "/api/v1/enclosures/#{enclosure.id}/occupants/#{animal.id}"

      expect(response).to have_http_status(:ok)
      expect(Housing.occupants_of(enclosure)).to be_empty
    end

    it '収容されていない個体を解放しようとすると404になること' do
      delete "/api/v1/enclosures/#{enclosure.id}/occupants/#{animal.id}"

      expect(response).to have_http_status(:not_found)
    end
  end
end
