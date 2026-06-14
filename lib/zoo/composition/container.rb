# frozen_string_literal: true

module Zoo
  module Composition
    # 合成の起点。in-memory 実装で依存を組み立て、ユースケース/クエリを供給する。
    # 永続化実装を差し替えるなら、変更はこのクラスに閉じる。
    class Container
      attr_reader :animals, :enclosures, :keepers, :veterinarians, :zoo,
                  :event_store, :memorial_log, :birth_announcements

      # 永続化の選択:
      #   database: を渡すと SQLite(実トランザクション・ファイル永続化)
      #   state:    を渡すと Snapshot から復元(in-memory)
      #   どちらも無ければ in-memory(揮発)
      def initialize(state: nil, database: nil)
        database ? setup_sqlite(database) : setup_in_memory(state)

        @memorial_log = Infrastructure::Subscribers::MemorialLog.new
        @birth_announcements = Infrastructure::Subscribers::BirthAnnouncementLog.new
        @event_dispatcher = Application::EventDispatcher.new(
          event_store: @event_store, subscribers: [@memorial_log, @birth_announcements]
        )
      end

      # 保存ファイルから状態を復元したコンテナを作る。
      def self.load(path)
        new(state: Infrastructure::Persistence::Snapshot.load(path))
      end

      # 全状態を1ファイルに保存する。
      def save(path)
        Infrastructure::Persistence::Snapshot.dump(
          {
            animals: @animals.all, enclosures: @enclosures.all,
            keepers: @keepers.all, veterinarians: @veterinarians.all,
            zoo: @zoo.load, events: @event_store.all
          },
          path
        )
      end

      def acquire_animal
        Application::Services::AcquireAnimal.new(animals: @animals, unit_of_work: @unit_of_work)
      end

      def rename_animal
        Application::Services::RenameAnimal.new(
          animals: @animals, event_dispatcher: @event_dispatcher, unit_of_work: @unit_of_work
        )
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

      def breed_animals
        Application::Services::BreedAnimals.new(
          animals: @animals, enclosures: @enclosures, zoo: @zoo,
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
        @animals = store::InMemoryAnimalRepository.new(state ? state[:animals] : [])
        @enclosures = store::InMemoryEnclosureRepository.new(state ? state[:enclosures] : [])
        @keepers = store::InMemoryKeeperRepository.new(state ? state[:keepers] : [])
        @veterinarians = store::InMemoryVeterinarianRepository.new(state ? state[:veterinarians] : [])
        @zoo = store::InMemoryZooRepository.new(state ? state[:zoo] : default_zoo)
        @event_store = store::InMemoryEventStore.new
        (state ? state[:events] : []).each { |event| @event_store.append(event) }
        # 書き込みを伴う(Snapshotable な)リポジトリのみ登録する。
        @unit_of_work = store::InMemoryUnitOfWork.new(
          repositories: [@animals, @enclosures, @keepers, @veterinarians]
        )
      end

      def setup_sqlite(path)
        sqlite = Infrastructure::Sqlite
        database = sqlite::Database.new(path)
        @animals = sqlite::AnimalRepository.new(database)
        @enclosures = sqlite::EnclosureRepository.new(database, @animals)
        @keepers = sqlite::KeeperRepository.new(database)
        @veterinarians = sqlite::VeterinarianRepository.new(database)
        @zoo = sqlite::ZooRepository.new(database, default_zoo)
        @event_store = sqlite::EventStore.new(database, @animals)
        @unit_of_work = sqlite::UnitOfWork.new(database)
      end

      def default_zoo
        Domain::Zoo.new(
          name: 'OOP動物園',
          admission_fee: Domain::Shared::Money.yen(2000),
          funds: Domain::Shared::Money.yen(100_000)
        )
      end
    end
  end
end
