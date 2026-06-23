# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class HireVeterinarian
        def initialize(veterinarians:, zoo:, unit_of_work:)
          @veterinarians = veterinarians
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            veterinarian = Domain::Veterinarian.new(name: command.name)

            zoo = @zoo.load
            zoo.purchase(Domain::Veterinarian.signing_fee)
            @zoo.save(zoo)

            @veterinarians.save(veterinarian)
            veterinarian
          end
        end
      end
    end
  end
end
