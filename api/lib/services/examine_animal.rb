# frozen_string_literal: true

module Services
  class ExamineAnimal
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:examine_animal) do
        vet = ::Veterinarian.find_by(id: @command.veterinarian_id)
        raise Errors::VeterinarianNotFound, "獣医 #{@command.veterinarian_id} は存在しません" if vet.nil?

        animal = ::Animal.find_by(id: @command.animal_id)
        raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

        { animal:, diagnosis: ::Examining.new(veterinarian: vet, animal: animal).diagnosis }
      end
    end
  end
end
