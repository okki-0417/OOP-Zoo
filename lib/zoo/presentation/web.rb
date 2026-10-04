# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module Zoo
  module Presentation
    class Web < Sinatra::Base
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

      get('/species') { respond(:species_list, commands::SpeciesListCommand.new) }
      get('/foods') { respond(:food_list, commands::FoodListCommand.new) }
      get('/taxon-classes') { respond(:taxon_class_list, commands::TaxonClassListCommand.new) }

      get('/animals') { respond(:animal_list, commands::AnimalListCommand.new) }
      post('/animals') do
        respond(:acquire_animal, commands::AcquireAnimalCommand.new(
                                   species_code: request_params['species'], name: request_params['name'], sex: request_params['sex']
                                 ))
      end
      get('/animals/:id') { respond(:animal_detail, commands::AnimalDetailCommand.new(animal_id: params['id'])) }
      patch('/animals/:id/name') do
        respond(:rename_animal, commands::RenameAnimalCommand.new(
                                  animal_id: params['id'], new_name: request_params['name']
                                ))
      end
      post('/animals/:id/feedings') do
        respond(:feed_animal, commands::FeedAnimalCommand.new(
                                keeper_id: request_params['keeper_id'], animal_id: params['id'], food_code: request_params['food']
                              ))
      end
      post('/animals/:id/treatments') do
        respond(:treat_animal, commands::TreatAnimalCommand.new(
                                 veterinarian_id: request_params['veterinarian_id'], animal_id: params['id']
                               ))
      end
      post('/animals/:id/examinations') do
        respond(:examine_animal, commands::ExamineAnimalCommand.new(
                                   veterinarian_id: request_params['veterinarian_id'], animal_id: params['id']
                                 ))
      end
      post('/animals/:id/transfer') do
        respond(:transfer_animal, commands::TransferAnimalCommand.new(
                                    animal_id: params['id'], enclosure_id: request_params['enclosure_id']
                                  ))
      end

      get('/enclosures') { respond(:enclosure_list, commands::EnclosureListCommand.new) }
      post('/enclosures') do
        respond(:add_enclosure, commands::AddEnclosureCommand.new(
                                  name: request_params['name'], celsius: integer('celsius'), capacity: integer('capacity')
                                ))
      end
      get('/enclosures/:id') do
        respond(:enclosure_detail, commands::EnclosureDetailCommand.new(enclosure_id: params['id']))
      end
      post('/enclosures/:id/occupants') do
        respond(:house_animal, commands::HouseAnimalCommand.new(
                                 enclosure_id: params['id'], animal_id: request_params['animal_id']
                               ))
      end
      delete('/enclosures/:id/occupants/:animal_id') do
        respond(:release_animal, commands::ReleaseAnimalCommand.new(animal_id: params['animal_id']))
      end
      post('/enclosures/:id/cleanings') do
        respond(:clean_enclosure, commands::CleanEnclosureCommand.new(
                                    keeper_id: request_params['keeper_id'], enclosure_id: params['id']
                                  ))
      end

      get('/keepers') { respond(:keeper_list, commands::KeeperListCommand.new) }
      post('/keepers') do
        respond(:hire_keeper, commands::HireKeeperCommand.new(
                                name: request_params['name'], specialties: request_params['specialties']
                              ))
      end
      get('/veterinarians') { respond(:veterinarian_list, commands::VeterinarianListCommand.new) }
      post('/veterinarians') do
        respond(:hire_veterinarian, commands::HireVeterinarianCommand.new(name: request_params['name']))
      end

      get('/report') { respond(:zoo_report, commands::ZooReportCommand.new) }
      get('/deceased') { respond(:deceased_list, commands::DeceasedListCommand.new) }
      get('/threatened') { respond(:threatened_species, commands::ThreatenedSpeciesCommand.new) }
      post('/visitors') { respond(:admit_visitors, commands::AdmitVisitorsCommand.new(count: integer('count'))) }
      patch('/admission-fee') do
        respond(:set_admission_fee, commands::SetAdmissionFeeCommand.new(fee: integer('fee')))
      end
      post('/operate') { respond(:operate_day, commands::OperateDayCommand.new) }
      post('/run-days') { respond(:run_days, commands::RunDaysCommand.new(days: integer('days'))) }

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

      def commands
        Application::Commands
      end

      def respond(use_case, command)
        code, data = container.public_send(use_case, command, renderer: Renderers::Json)
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
