# frozen_string_literal: true

module Services
  class NameAnimal
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:name_animal) do
        ApplicationRecord.transaction do
          animal = ::Animal.find_by(id: @command.animal_id)
          raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

          animal.name_animal(name: @command.name)
          animal.save!
        end
        nil
      end
    end
  end
end
