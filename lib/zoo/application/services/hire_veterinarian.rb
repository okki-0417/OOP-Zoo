# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class HireVeterinarian
        def initialize(veterinarians:, unit_of_work:)
          @veterinarians = veterinarians
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            veterinarian = Domain::Staff::Veterinarian.new(name: command.name)
            @veterinarians.save(veterinarian)
            veterinarian
          end
        end
      end
    end
  end
end
