# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Acquire < Command
        def run(args)
          species_key, name, sex_key = args
          raise ArgumentError, '使い方: acquire SPECIES NAME SEX' if [species_key, name, sex_key].any?(&:nil?)

          command = Application::Commands::AcquireAnimalCommand.new(
            species: resolve_species(species_key),
            name: name,
            sex: Domain::Animal::Sex.new(sex_key),
            max_health: 100
          )
          animal = @container.acquire_animal.call(command)
          @output.puts "受け入れました: #{animal.name}（id=#{animal.id}）"
        end

        private

        def resolve_species(key)
          Domain::Taxonomy::SpeciesCatalog.find(key) or raise ArgumentError, "未知の種です: #{key}"
        end
      end
    end
  end
end
