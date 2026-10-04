# frozen_string_literal: true

module ToolsFactory
  Tools = Data.define(
    :animals, :enclosures, :housings, :keepers, :veterinarians, :breedings, :births,
    :assignments, :operatings, :species, :foods, :zoo, :unit_of_work
  )

  def build_tools(funds: 100_000, admission_fee: 2_000)
    store = Zoo::Infrastructure::InMemory
    transactional = {
      animals: store::InMemoryAnimalRepository.new,
      enclosures: store::InMemoryEnclosureRepository.new,
      housings: store::InMemoryHousingRepository.new,
      keepers: store::InMemoryKeeperRepository.new,
      veterinarians: store::InMemoryVeterinarianRepository.new,
      breedings: store::InMemoryBreedingRepository.new,
      births: store::InMemoryBirthRepository.new,
      assignments: store::InMemoryAssignmentRepository.new,
      operatings: store::InMemoryOperatingRepository.new
    }

    Tools.new(
      **transactional,
      species: store::InMemorySpeciesRepository.new,
      foods: store::InMemoryFoodRepository.new,
      zoo: store::InMemoryZooRepository.new(build_zoo(funds:, admission_fee:)),
      unit_of_work: store::InMemoryUnitOfWork.new(repositories: transactional.values)
    )
  end

  def build_zoo(funds: 100_000, admission_fee: 2_000)
    money = Zoo::Domain::Shared::Money
    Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: money.yen(admission_fee), funds: money.yen(funds))
  end

  def call_service(command, tools:)
    described_class.new(command: command.bind(**tools.to_h)).call
  end
end

RSpec.configure do |config|
  config.include ToolsFactory
end
