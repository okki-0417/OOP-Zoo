# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class FeedAnimalCommand < CommandFactory
    target ::Zoo::Application::Commands::FeedAnimalCommand

    defaults do |keepers:, animals:, **|
      keeper = build_keeper
      animal = build_adult(::Zoo::Domain::SpeciesCatalog.lion, name: 'レオ')
      keepers.save(keeper)
      animals.save(animal)

      { keeper_id: keeper.id, animal_id: animal.id, food_code: 'horse_meat' }
    end
  end
end
