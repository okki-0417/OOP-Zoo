# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Breed < Command
        def run(args)
          sire_id, dam_id, enclosure_id, name, sex_key = args
          if [sire_id, dam_id, enclosure_id, name, sex_key].any?(&:nil?)
            raise ArgumentError, '使い方: breed SIRE_ID DAM_ID ENCLOSURE_ID NAME SEX'
          end

          command = Application::Commands::BreedAnimalsCommand.new(
            sire_id: sire_id, dam_id: dam_id, enclosure_id: enclosure_id,
            name: name, sex: Domain::Animal::Sex.new(sex_key)
          )
          child = @container.breed_animals.call(command)
          @output.puts "誕生しました: #{child.name}（id=#{child.id}）"
        end
      end
    end
  end
end
