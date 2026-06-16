# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      class AnimalMapper
        Domain = Zoo::Domain
        Catalog = Domain::Taxonomy::SpeciesCatalog
        Illnesses = Domain::Medical::IllnessCatalog

        def to_row(animal)
          {
            id: animal.id.to_s,
            species_key: species_key(animal.species).to_s,
            name: animal.name.to_s,
            sex: animal.sex.value.to_s,
            health_current: animal.health.current,
            health_max: animal.health.max,
            hunger: animal.hunger.level,
            stress: animal.stress.level,
            age_in_days: animal.age_in_days.value,
            illness_key: animal.illness && illness_key(animal.illness)&.to_s,
            immunities: animal.immunities.map { |ill| illness_key(ill)&.to_s }.compact.join(','),
            death_cause: animal.death&.cause&.to_s,
            parent_ids: animal.parent_ids.join(',')
          }
        end

        def to_aggregate(row)
          Domain::Animal.reconstitute(
            id: Domain::Shared::Identifier.new(row['id']),
            species: Catalog.find(row['species_key']),
            name: Domain::Animal::Name.new(row['name']),
            sex: Domain::Animal::Sex.new(row['sex']),
            health: Domain::Animal::Health.new(current: row['health_current'], max: row['health_max']),
            hunger: Domain::Animal::Hunger.new(row['hunger']),
            stress: Domain::Animal::Stress.new(row['stress']),
            age_in_days: Domain::Animal::AgeInDays.new(row['age_in_days']),
            illness: row['illness_key'] && Illnesses.find(row['illness_key']),
            immunities: parse_immunities(row['immunities']),
            death: row['death_cause'] && Domain::Animal::Death.new(cause: row['death_cause'].to_sym),
            parent_ids: parse_parent_ids(row['parent_ids'])
          )
        end

        private

        def species_key(species)
          Catalog.keys.find { |key| Catalog.find(key) == species }
        end

        def illness_key(illness)
          Illnesses.keys.find { |key| Illnesses.find(key) == illness }
        end

        def parse_parent_ids(value)
          value.to_s.split(',').reject(&:empty?).map { |id| Domain::Shared::Identifier.new(id) }
        end

        def parse_immunities(value)
          value.to_s.split(',').reject(&:empty?).map { |key| Illnesses.find(key) }.compact
        end
      end
    end
  end
end
