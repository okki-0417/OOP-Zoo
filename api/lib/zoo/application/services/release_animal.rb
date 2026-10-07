# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class ReleaseAnimal
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:release_animal) do
            ApplicationRecord.transaction do
              animal = Domain::Animal.find_by(id: @command.animal_id)
              raise Errors::AnimalNotFound, "動物 #{@command.animal_id} は存在しません" if animal.nil?

              raise ArgumentError, "#{animal.name}はどのエリアにも収容されていません" if animal.enclosure.nil?

              animal.move_out.save!
              animal
            end
          end
        end
      end
    end
  end
end
