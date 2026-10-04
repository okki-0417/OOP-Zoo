# frozen_string_literal: true

module Zoo
  module Composition
    class Container
      attr_reader :animals, :enclosures, :housings, :keepers, :veterinarians, :breedings, :births, :assignments,
                  :operatings, :zoo

      def initialize(state: nil, database: nil)
        database ? setup_sqlite(database) : setup_in_memory(state)
      end

      def self.load(path)
        new(state: Infrastructure::Persistence::Snapshot.load(path))
      end

      def save(path)
        Infrastructure::Persistence::Snapshot.dump(
          {
            animals: @animals.all, enclosures: @enclosures.all, housings: @housings.all,
            keepers: @keepers.all, veterinarians: @veterinarians.all,
            breedings: @breedings.all, births: @births.all, assignments: @assignments.all,
            operatings: @operatings.all, zoo: @zoo.load
          },
          path
        )
      end

      SERVICES = {
        acquire_animal: Application::Services::AcquireAnimal,
        add_enclosure: Application::Services::AddEnclosure,
        admit_visitors: Application::Services::AdmitVisitors,
        assign_keeper: Application::Services::AssignKeeper,
        clean_enclosure: Application::Services::CleanEnclosure,
        conceive_animals: Application::Services::ConceiveAnimals,
        deliver_animal: Application::Services::DeliverAnimal,
        discharge_keeper: Application::Services::DischargeKeeper,
        examine_animal: Application::Services::ExamineAnimal,
        feed_animal: Application::Services::FeedAnimal,
        hire_keeper: Application::Services::HireKeeper,
        hire_veterinarian: Application::Services::HireVeterinarian,
        house_animal: Application::Services::HouseAnimal,
        name_animal: Application::Services::NameAnimal,
        open_for_a_day: Application::Services::OpenForADay,
        operate_day: Application::Services::OperateDay,
        release_animal: Application::Services::ReleaseAnimal,
        rename_animal: Application::Services::RenameAnimal,
        run_days: Application::Services::RunDays,
        set_admission_fee: Application::Services::SetAdmissionFee,
        transfer_animal: Application::Services::TransferAnimal,
        treat_animal: Application::Services::TreatAnimal,
        animal_detail: Application::Queries::AnimalDetail,
        animal_list: Application::Queries::AnimalList,
        deceased_list: Application::Queries::DeceasedList,
        enclosure_detail: Application::Queries::EnclosureDetail,
        enclosure_list: Application::Queries::EnclosureList,
        keeper_list: Application::Queries::KeeperList,
        operating_history: Application::Queries::OperatingHistory,
        population: Application::Queries::Population,
        revenue: Application::Queries::Revenue,
        threatened_species: Application::Queries::ThreatenedSpecies,
        veterinarian_list: Application::Queries::VeterinarianList,
        zoo_report: Application::Queries::ZooReport,
        species_list: Application::Queries::SpeciesList,
        food_list: Application::Queries::FoodList,
        taxon_class_list: Application::Queries::TaxonClassList
      }.freeze

      SERVICES.each do |name, service_class|
        define_method(name) do |command, renderer:|
          renderer.render(call_application_service(service_class, command))
        end
      end

      private

      def call_application_service(service_class, command)
        service_class.new(command: command.bind(unit_of_work: @unit_of_work, **repositories)).call
      end

      def repositories
        {
          animals: @animals, enclosures: @enclosures, housings: @housings, keepers: @keepers,
          veterinarians: @veterinarians, breedings: @breedings, births: @births,
          assignments: @assignments, operatings: @operatings, species: @species, foods: @foods, zoo: @zoo
        }
      end

      def setup_in_memory(state)
        store = Infrastructure::InMemory
        state ||= {}
        @animals = store::InMemoryAnimalRepository.new(state.fetch(:animals, []))
        @enclosures = store::InMemoryEnclosureRepository.new(state.fetch(:enclosures, []))
        @housings = store::InMemoryHousingRepository.new(state.fetch(:housings, []))
        @keepers = store::InMemoryKeeperRepository.new(state.fetch(:keepers, []))
        @veterinarians = store::InMemoryVeterinarianRepository.new(state.fetch(:veterinarians, []))
        @breedings = store::InMemoryBreedingRepository.new(state.fetch(:breedings, []))
        @births = store::InMemoryBirthRepository.new(state.fetch(:births, []))
        @assignments = store::InMemoryAssignmentRepository.new(state.fetch(:assignments, []))
        @operatings = store::InMemoryOperatingRepository.new(state.fetch(:operatings, []))
        @zoo = store::InMemoryZooRepository.new(state.fetch(:zoo, default_zoo))
        @species = store::InMemorySpeciesRepository.new
        @foods = store::InMemoryFoodRepository.new

        @unit_of_work = store::InMemoryUnitOfWork.new(
          repositories: [@animals, @enclosures, @housings, @keepers, @veterinarians, @breedings, @births,
                         @assignments, @operatings]
        )
      end

      def setup_sqlite(path)
        sqlite = Infrastructure::Sqlite
        database = sqlite::Database.new(path)
        @animals = sqlite::AnimalRepository.new(database)
        @enclosures = sqlite::EnclosureRepository.new(database)
        @housings = sqlite::HousingRepository.new(database, @animals, @enclosures)
        @keepers = sqlite::KeeperRepository.new(database)
        @veterinarians = sqlite::VeterinarianRepository.new(database)
        @breedings = sqlite::BreedingRepository.new(database, @animals)
        @births = sqlite::BirthRepository.new(database, @animals)
        @assignments = sqlite::AssignmentRepository.new(database, @keepers, @enclosures)
        @operatings = sqlite::OperatingRepository.new(database)
        @zoo = sqlite::ZooRepository.new(database, default_zoo)
        @species = Infrastructure::InMemory::InMemorySpeciesRepository.new
        @foods = Infrastructure::InMemory::InMemoryFoodRepository.new
        @unit_of_work = sqlite::UnitOfWork.new(database)
      end

      def default_zoo
        Domain::Zoo.new(
          name: 'OOP動物園',
          admission_fee: Domain::Shared::Money.yen(2000),
          funds: Domain::Shared::Money.yen(1_000_000)
        )
      end
    end
  end
end
