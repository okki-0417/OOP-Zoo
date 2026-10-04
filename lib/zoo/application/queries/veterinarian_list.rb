# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class VeterinarianList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:veterinarian_list) do
            @command.veterinarians.all.map { |vet| ReadModels::VeterinarianSummary.of(vet) }
          end
        end
      end
    end
  end
end
