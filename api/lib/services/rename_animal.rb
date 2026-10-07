# frozen_string_literal: true

module Services
  class RenameAnimal
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:rename_animal) do
        ApplicationRecord.transaction do
          animal = ::Animal.find_by(id: @command.animal_id)
          raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

          animal.change_name(@command.new_name)
          animal.save!
          animal
        end
      end
    end
  end
end
