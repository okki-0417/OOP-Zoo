# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class VeterinarianList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:veterinarian_list) do
            @command.veterinarians.all
          end
        end
      end
    end
  end
end
