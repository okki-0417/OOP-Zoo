# frozen_string_literal: true

module Services
  class HireVeterinarian
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:hire_veterinarian) do
        ApplicationRecord.transaction do
          veterinarian = ::Veterinarian.new(name: @command.name)

          zoo = ::Zoo.current
          zoo.purchase(::Veterinarian.signing_fee)
          zoo.save!

          veterinarian.save!
          veterinarian
        end
      end
    end
  end
end
