# frozen_string_literal: true

require_relative '../factories'
require_relative 'repositories'

module Factory
  class CommandFactory
    extend ::Factories

    REPOSITORIES = {
      animals: AnimalRepository, enclosures: EnclosureRepository, housings: HousingRepository,
      keepers: KeeperRepository, veterinarians: VeterinarianRepository, breedings: BreedingRepository,
      births: BirthRepository, assignments: AssignmentRepository, operatings: OperatingRepository,
      species: SpeciesRepository, foods: FoodRepository, zoo: ZooRepository
    }.freeze
    TRANSACTIONAL = %i[animals enclosures housings keepers veterinarians breedings births assignments operatings].freeze
    TOOL_NAMES = [*REPOSITORIES.keys, :unit_of_work].freeze

    class << self
      def target(command_class)
        @command_class = command_class
      end

      def defaults(&block)
        @defaults = block
      end

      def build(**overrides)
        @command_class.new(**default_inputs(default_repositories), **overrides)
      end

      def with_bind(**overrides)
        repositories = default_repositories.merge(overrides.slice(*REPOSITORIES.keys))
        unit_of_work = overrides.fetch(:unit_of_work) { UnitOfWork.build(*repositories.values_at(*TRANSACTIONAL)) }
        tools = { **repositories, unit_of_work: }

        @command_class.new(**default_inputs(repositories), **overrides.except(*TOOL_NAMES)).bind(**tools)
      end

      private

      def default_repositories
        REPOSITORIES.transform_values(&:build)
      end

      def default_inputs(repositories)
        @defaults ? instance_exec(**repositories, &@defaults) : {}
      end

      def build_enclosure
        ::Zoo::Domain::Enclosure.new(
          name: 'ライオンの丘', temperature: ::Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
        )
      end
    end
  end
end
