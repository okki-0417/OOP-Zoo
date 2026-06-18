# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class HireKeeper < Action
        def call(params)
          keys = params['specialties']
          raise ArgumentError, 'specialties は配列で指定してください' unless keys.is_a?(Array)

          specialties = keys.map { |key| Domain::TaxonClass.new(key) }
          command = Application::Commands::HireKeeperCommand.new(name: params['name'], specialties: specialties)
          keeper = @container.hire_keeper.call(command)
          summary = @container.keeper_list.call.find { |k| k.id == keeper.id.to_s }
          [201, Serializer.keeper(summary)]
        end
      end
    end
  end
end
