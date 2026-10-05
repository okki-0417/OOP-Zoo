# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module Zoo
  module Presentation
    class Rest < Sinatra::Base
      set :container, nil
      set :raise_errors, false
      set :show_exceptions, false
      set :host_authorization, { permitted_hosts: [] }

      before do
        headers 'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => 'GET, POST, PATCH, DELETE, OPTIONS',
                'Access-Control-Allow-Headers' => 'Content-Type'
      end

      options('*') { 200 }

      error(ArgumentError) { error_json(400) }

      get('/species') { respond(:species_list) }
      get('/foods') { respond(:food_list) }
      get('/taxon-classes') { respond(:taxon_class_list) }

      get('/animals') { respond(:animal_list) }
      post('/animals') { respond(:acquire_animal, :species_code, :name, :sex) }
      get('/animals/:animal_id') { respond(:animal_detail, :animal_id) }
      get('/animals/:animal_id/prognosis') { respond(:animal_prognosis, :animal_id) }
      patch('/animals/:animal_id/name') { respond(:rename_animal, :animal_id, :new_name) }
      post('/animals/:animal_id/feedings') { respond(:feed_animal, :animal_id, :keeper_id, :food_code) }
      post('/animals/:animal_id/treatments') { respond(:treat_animal, :animal_id, :veterinarian_id) }
      post('/animals/:animal_id/examinations') { respond(:examine_animal, :animal_id, :veterinarian_id) }
      post('/animals/:animal_id/transfer') { respond(:transfer_animal, :animal_id, :enclosure_id) }

      get('/enclosures') { respond(:enclosure_list) }
      post('/enclosures') do
        respond(:add_enclosure, :name, celsius: integer('celsius'), capacity: integer('capacity'))
      end
      get('/enclosures/:enclosure_id') { respond(:enclosure_detail, :enclosure_id) }
      post('/enclosures/:enclosure_id/occupants') { respond(:house_animal, :enclosure_id, :animal_id) }
      delete('/enclosures/:enclosure_id/occupants/:animal_id') { respond(:release_animal, :animal_id) }
      post('/enclosures/:enclosure_id/cleanings') { respond(:clean_enclosure, :enclosure_id, :keeper_id) }
      post('/enclosures/:enclosure_id/enrichments') { respond(:enrich_enclosure, :enclosure_id, :keeper_id) }
      post('/enclosures/:enclosure_id/keepers') { respond(:assign_keeper, :enclosure_id, :keeper_id) }
      delete('/enclosures/:enclosure_id/keepers/:keeper_id') { respond(:discharge_keeper, :enclosure_id, :keeper_id) }

      get('/keepers') { respond(:keeper_list) }
      post('/keepers') { respond(:hire_keeper, :name, :specialties) }
      post('/keepers/:keeper_id/rounds') { respond(:make_rounds, :keeper_id) }
      get('/veterinarians') { respond(:veterinarian_list) }
      post('/veterinarians') { respond(:hire_veterinarian, :name) }

      get('/report') { respond(:zoo_report) }
      get('/alerts') { respond(:alert_list) }
      get('/checklist') { respond(:checklist) }
      get('/operatings') { respond(:operating_history) }
      get('/deceased') { respond(:deceased_list) }
      get('/threatened') { respond(:threatened_species) }
      post('/visitors') { respond(:admit_visitors, count: integer('count')) }
      patch('/admission-fee') { respond(:set_admission_fee, fee: integer('fee')) }
      post('/operate') { respond(:operate_day) }
      post('/run-days') { respond(:run_days, days: integer('days')) }

      private

      def container
        settings.container ||= Zoo::Composition::Container.new
      end

      def request_params
        @request_params ||= parse_request_params
      end

      def parse_request_params
        return params unless request.media_type == 'application/json' && request.content_length.to_i.positive?

        body = JSON.parse(request.body.read)
        request.body.rewind
        (body.is_a?(Hash) ? body : {}).merge(params)
      end

      def integer(key)
        Integer(request_params[key].to_s)
      end

      def command_for(use_case, keys, converted)
        attributes = keys.to_h { |key| [key, request_params[key.to_s]] }.merge(converted)
        Application::Commands.const_get("#{use_case.to_s.split('_').map(&:capitalize).join}Command").new(**attributes)
      end

      def respond(use_case, *keys, **converted)
        code, data = container.public_send(use_case, command_for(use_case, keys, converted), renderer: Renderers::Json)
        content_type :json
        status code
        data.to_json
      end

      def error_json(code)
        error = env['sinatra.error']
        content_type :json
        status code
        { error: { code: error.class.name.split('::').last, message: error.message } }.to_json
      end
    end
  end
end
