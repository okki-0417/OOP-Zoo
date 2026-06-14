# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class BreedAnimals < Action
        def call
          sire_id = choose_animal('父個体') or return @output.puts('個体がいません')
          dam_id = choose_animal('母個体') or return @output.puts('個体がいません')
          enclosure_id = choose_enclosure('子の収容先') or return @output.puts('エリアがありません')
          name = @prompt.ask('子の名前:')
          sex = @prompt.select('子の性別', %w[male female])

          child = @container.breed_animals.call(
            Application::Commands::BreedAnimalsCommand.new(
              sire_id: sire_id, dam_id: dam_id, enclosure_id: enclosure_id,
              name: name, sex: Domain::Animal::Sex.new(sex)
            )
          )
          @output.puts "誕生しました: #{child.name}"
        end
      end
    end
  end
end
