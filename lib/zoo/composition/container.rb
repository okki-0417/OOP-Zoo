# frozen_string_literal: true

module Zoo
  module Composition
    class Container
      attr_reader :animals, :enclosures, :keepers, :veterinarians, :breedings, :births, :zoo,
                  :event_store, :memorial_log, :birth_announcements

      def initialize(state: nil, database: nil)
        database ? setup_sqlite(database) : setup_in_memory(state)

        @memorial_log = Infrastructure::Subscribers::MemorialLog.new
        @birth_announcements = Infrastructure::Subscribers::BirthAnnouncementLog.new
        @event_dispatcher = Application::EventDispatcher.new(
          event_store: @event_store, subscribers: [@memorial_log, @birth_announcements]
        )
      end

      def self.load(path)
        new(state: Infrastructure::Persistence::Snapshot.load(path))
      end

      def save(path)
        Infrastructure::Persistence::Snapshot.dump(
          {
            animals: @animals.all, enclosures: @enclosures.all,
            keepers: @keepers.all, veterinarians: @veterinarians.all,
            breedings: @breedings.all, births: @births.all, zoo: @zoo.load, events: @event_store.all
          },
          path
        )
      end

      def acquire_animal
        Application::Services::AcquireAnimal.new(animals: @animals, zoo: @zoo, unit_of_work: @unit_of_work)
      end

      def rename_animal
        Application::Services::RenameAnimal.new(
          animals: @animals, event_dispatcher: @event_dispatcher, unit_of_work: @unit_of_work
        )
      end

      def add_enclosure
        Application::Services::AddEnclosure.new(enclosures: @enclosures, zoo: @zoo, unit_of_work: @unit_of_work)
      end

      def hire_keeper
        Application::Services::HireKeeper.new(keepers: @keepers, zoo: @zoo, unit_of_work: @unit_of_work)
      end

      def hire_veterinarian
        Application::Services::HireVeterinarian.new(
          veterinarians: @veterinarians, zoo: @zoo, unit_of_work: @unit_of_work
        )
      end

      def admit_visitors
        Application::Services::AdmitVisitors.new(zoo: @zoo, unit_of_work: @unit_of_work)
      end

      def set_admission_fee
        Application::Services::SetAdmissionFee.new(zoo: @zoo, unit_of_work: @unit_of_work)
      end

      def examine_animal
        Application::Services::ExamineAnimal.new(
          veterinarians: @veterinarians, animals: @animals, unit_of_work: @unit_of_work
        )
      end

      def transfer_animal
        Application::Services::TransferAnimal.new(
          enclosures: @enclosures, animals: @animals, unit_of_work: @unit_of_work
        )
      end

      def release_animal
        Application::Services::ReleaseAnimal.new(
          enclosures: @enclosures, animals: @animals, unit_of_work: @unit_of_work
        )
      end

      def house_animal
        Application::Services::HouseAnimal.new(enclosures: @enclosures, animals: @animals, unit_of_work: @unit_of_work)
      end

      def feed_animal
        Application::Services::FeedAnimal.new(keepers: @keepers, animals: @animals, unit_of_work: @unit_of_work)
      end

      def treat_animal
        Application::Services::TreatAnimal.new(
          veterinarians: @veterinarians, animals: @animals, unit_of_work: @unit_of_work
        )
      end

      def clean_enclosure
        Application::Services::CleanEnclosure.new(
          keepers: @keepers, enclosures: @enclosures, unit_of_work: @unit_of_work
        )
      end

      def conceive_animals
        Application::Services::ConceiveAnimals.new(
          animals: @animals, breedings: @breedings, zoo: @zoo,
          event_dispatcher: @event_dispatcher, unit_of_work: @unit_of_work
        )
      end

      def deliver_animal
        Application::Services::DeliverAnimal.new(
          animals: @animals, enclosures: @enclosures, keepers: @keepers,
          breedings: @breedings, births: @births, zoo: @zoo,
          event_dispatcher: @event_dispatcher, unit_of_work: @unit_of_work
        )
      end

      def name_animal
        Application::Services::NameAnimal.new(
          animals: @animals, keepers: @keepers, zoo: @zoo,
          event_dispatcher: @event_dispatcher, unit_of_work: @unit_of_work
        )
      end

      def open_for_a_day
        Application::Services::OpenForADay.new(
          enclosures: @enclosures, animals: @animals,
          event_dispatcher: @event_dispatcher, unit_of_work: @unit_of_work
        )
      end

      def run_days
        Application::Services::RunDays.new(open_for_a_day: open_for_a_day)
      end

      def operate_day
        Application::Services::OperateDay.new(
          open_for_a_day: open_for_a_day,
          enclosures: @enclosures, animals: @animals,
          keepers: @keepers, veterinarians: @veterinarians,
          zoo: @zoo, unit_of_work: @unit_of_work
        )
      end

      def threatened_species
        Application::Queries::ThreatenedSpecies.new(enclosures: @enclosures)
      end

      def population
        Application::Queries::Population.new(enclosures: @enclosures)
      end

      def revenue
        Application::Queries::Revenue.new(zoo: @zoo)
      end

      def zoo_report
        Application::Queries::ZooReport.new(enclosures: @enclosures, event_store: @event_store, zoo: @zoo,
                                            animals: @animals, births: @births)
      end

      def enclosure_list
        Application::Queries::EnclosureList.new(enclosures: @enclosures)
      end

      def animal_list
        Application::Queries::AnimalList.new(animals: @animals)
      end

      def keeper_list
        Application::Queries::KeeperList.new(keepers: @keepers)
      end

      def veterinarian_list
        Application::Queries::VeterinarianList.new(veterinarians: @veterinarians)
      end

      def animal_detail
        Application::Queries::AnimalDetail.new(animals: @animals, enclosures: @enclosures)
      end

      def enclosure_detail
        Application::Queries::EnclosureDetail.new(enclosures: @enclosures)
      end

      def deceased_list
        Application::Queries::DeceasedList.new(event_store: @event_store)
      end

      private

      def setup_in_memory(state)
        store = Infrastructure::InMemory
        state ||= {}
        @animals = store::InMemoryAnimalRepository.new(state.fetch(:animals, []))
        @enclosures = store::InMemoryEnclosureRepository.new(state.fetch(:enclosures, []))
        @keepers = store::InMemoryKeeperRepository.new(state.fetch(:keepers, []))
        @veterinarians = store::InMemoryVeterinarianRepository.new(state.fetch(:veterinarians, []))
        @breedings = store::InMemoryBreedingRepository.new(state.fetch(:breedings, []))
        @births = store::InMemoryBirthRepository.new(state.fetch(:births, []))
        @zoo = store::InMemoryZooRepository.new(state.fetch(:zoo, default_zoo))
        @event_store = store::InMemoryEventStore.new
        state.fetch(:events, []).each { |event| @event_store.append(event) }

        @unit_of_work = store::InMemoryUnitOfWork.new(
          repositories: [@animals, @enclosures, @keepers, @veterinarians, @breedings, @births]
        )
      end

      def setup_sqlite(path)
        sqlite = Infrastructure::Sqlite
        database = sqlite::Database.new(path)
        @animals = sqlite::AnimalRepository.new(database)
        @enclosures = sqlite::EnclosureRepository.new(database, @animals)
        @keepers = sqlite::KeeperRepository.new(database)
        @veterinarians = sqlite::VeterinarianRepository.new(database)
        @breedings = sqlite::BreedingRepository.new(database, @animals)
        @births = sqlite::BirthRepository.new(database, @animals)
        @zoo = sqlite::ZooRepository.new(database, default_zoo)
        @event_store = sqlite::EventStore.new(database, @animals)
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
