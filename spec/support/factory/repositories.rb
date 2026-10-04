# frozen_string_literal: true

module Factory
  InMemory = ::Zoo::Infrastructure::InMemory

  module AnimalRepository
    def self.build(animals = []) = InMemory::InMemoryAnimalRepository.new(animals)
  end

  module EnclosureRepository
    def self.build(enclosures = []) = InMemory::InMemoryEnclosureRepository.new(enclosures)
  end

  module HousingRepository
    def self.build(housings = []) = InMemory::InMemoryHousingRepository.new(housings)
  end

  module KeeperRepository
    def self.build(keepers = []) = InMemory::InMemoryKeeperRepository.new(keepers)
  end

  module VeterinarianRepository
    def self.build(veterinarians = []) = InMemory::InMemoryVeterinarianRepository.new(veterinarians)
  end

  module BreedingRepository
    def self.build(breedings = []) = InMemory::InMemoryBreedingRepository.new(breedings)
  end

  module BirthRepository
    def self.build(births = []) = InMemory::InMemoryBirthRepository.new(births)
  end

  module AssignmentRepository
    def self.build(assignments = []) = InMemory::InMemoryAssignmentRepository.new(assignments)
  end

  module OperatingRepository
    def self.build(operatings = []) = InMemory::InMemoryOperatingRepository.new(operatings)
  end

  module SpeciesRepository
    def self.build = InMemory::InMemorySpeciesRepository.new
  end

  module FoodRepository
    def self.build = InMemory::InMemoryFoodRepository.new
  end

  module ZooRepository
    def self.build(funds: 100_000, admission_fee: 2_000)
      money = ::Zoo::Domain::Shared::Money
      InMemory::InMemoryZooRepository.new(
        ::Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: money.yen(admission_fee), funds: money.yen(funds))
      )
    end
  end

  module UnitOfWork
    def self.build(*repositories) = InMemory::InMemoryUnitOfWork.new(repositories:)
  end
end
