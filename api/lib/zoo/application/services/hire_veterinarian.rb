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
            ApplicationRecord.transaction do
              veterinarian = Domain::Veterinarian.new(name: @command.name)

              zoo = Domain::Zoo.current
              zoo.purchase(Domain::Veterinarian.signing_fee)
              zoo.save!

              veterinarian.save!
              veterinarian
            end
          end
        end
      end
    end
  end
end
