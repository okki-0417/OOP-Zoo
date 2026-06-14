# frozen_string_literal: true

module Zoo
  module Composition
    # 合成の起点。in-memory 実装で依存を組み立て、ユースケース/クエリを供給する。
    # 永続化実装を差し替えるなら、変更はこのクラスに閉じる。
    class Container
      attr_reader :animals, :enclosures, :keepers, :veterinarians, :zoo,
                  :event_store, :memorial_log, :birth_announcements

      def initialize
        store = Infrastructure::InMemory
        @animals = store::InMemoryAnimalRepository.new
        @enclosures = store::InMemoryEnclosureRepository.new
        @keepers = store::InMemoryKeeperRepository.new
        @veterinarians = store::InMemoryVeterinarianRepository.new
        @zoo = store::InMemoryZooRepository.new(
          Domain::Zoo.new(
            name: 'OOP動物園',
            admission_fee: Domain::Shared::Money.yen(2000),
            funds: Domain::Shared::Money.yen(100_000)
          )
        )

        @event_store = store::InMemoryEventStore.new
        @memorial_log = Infrastructure::Subscribers::MemorialLog.new
        @birth_announcements = Infrastructure::Subscribers::BirthAnnouncementLog.new
        @event_dispatcher = Application::EventDispatcher.new(
          event_store: @event_store, subscribers: [@memorial_log, @birth_announcements]
        )

        # 書き込みを伴う(Snapshotable な)リポジトリのみ登録する。
        @unit_of_work = store::InMemoryUnitOfWork.new(
          repositories: [@animals, @enclosures, @keepers, @veterinarians]
        )
      end

      def acquire_animal
        Application::Services::AcquireAnimal.new(animals: @animals, unit_of_work: @unit_of_work)
      end

      def add_enclosure
        Application::Services::AddEnclosure.new(enclosures: @enclosures, unit_of_work: @unit_of_work)
      end

      def hire_keeper
        Application::Services::HireKeeper.new(keepers: @keepers, unit_of_work: @unit_of_work)
      end

      def hire_veterinarian
        Application::Services::HireVeterinarian.new(veterinarians: @veterinarians, unit_of_work: @unit_of_work)
      end

      def admit_visitors
        Application::Services::AdmitVisitors.new(zoo: @zoo, unit_of_work: @unit_of_work)
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

      def breed_animals
        Application::Services::BreedAnimals.new(
          animals: @animals, enclosures: @enclosures,
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
        Application::Queries::ZooReport.new(enclosures: @enclosures, event_store: @event_store, zoo: @zoo)
      end

      def enclosure_list
        Application::Queries::EnclosureList.new(enclosures: @enclosures)
      end

      def animal_list
        Application::Queries::AnimalList.new(animals: @animals)
      end
    end
  end
end
