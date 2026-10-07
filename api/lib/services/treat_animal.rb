# frozen_string_literal: true

module Services
  class TreatAnimal
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:treat_animal) do
        ApplicationRecord.transaction do
          vet = ::Veterinarian.find_by(id: @command.veterinarian_id)
          raise Errors::VeterinarianNotFound, "獣医 #{@command.veterinarian_id} は存在しません" if vet.nil?

          animal = ::Animal.find_by(id: @command.animal_id)
          raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

          ::Treating.new(veterinarian: vet, animal: animal).perform
          animal.save!
          animal
        end
      end
    end
  end
end
