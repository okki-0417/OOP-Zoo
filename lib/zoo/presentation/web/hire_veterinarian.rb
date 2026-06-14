# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class HireVeterinarian < Action
        def call(params)
          command = Application::Commands::HireVeterinarianCommand.new(name: params['name'])
          vet = @container.hire_veterinarian.call(command)
          summary = @container.veterinarian_list.call.find { |v| v.id == vet.id.to_s }
          [201, Serializer.veterinarian(summary)]
        end
      end
    end
  end
end
