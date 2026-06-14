# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class BreedAnimals < Action
        def call(params)
          command = Application::Commands::BreedAnimalsCommand.new(
            sire_id: params['sire_id'], dam_id: params['dam_id'], enclosure_id: params['enclosure_id'],
            name: params['name'], sex: Domain::Animal::Sex.new(params['sex'].to_s)
          )
          child = @container.breed_animals.call(command)
          [201, Serializer.animal(@container.animal_detail.call(child.id))]
        end
      end
    end
  end
end
