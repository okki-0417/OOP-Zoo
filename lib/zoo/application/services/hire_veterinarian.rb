# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class HireVeterinarian
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:hire_veterinarian) do
            @command.unit_of_work.run do
              veterinarian = Domain::Veterinarian.new(name: @command.name)

              zoo = @command.zoo.load
              zoo.purchase(Domain::Veterinarian.signing_fee)
              @command.zoo.save(zoo)

              @command.veterinarians.save(veterinarian)
              veterinarian
            end
          end
        end
      end
    end
  end
end
