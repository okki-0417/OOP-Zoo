# frozen_string_literal: true

module Zoo
  module Presentation
    class Tui
      class AcquireAnimal < Action
        def call
          species_key = @prompt.select('種を選択', Domain::Taxonomy::SpeciesCatalog.keys, filter: true)
          name = @prompt.ask('名前:')
          sex = @prompt.select('性別', %w[male female])

          command = Application::Commands::AcquireAnimalCommand.new(
            species: Domain::Taxonomy::SpeciesCatalog.find(species_key),
            name: name, sex: Domain::Animal::Sex.new(sex), max_health: 100
          )
          animal = @container.acquire_animal.call(command)
          @output.puts "受け入れました: #{animal.name}"
        end
      end
    end
  end
end
