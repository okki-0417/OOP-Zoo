# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      # Keeper 集約 ⇄ 行。専門綱(TaxonClass の配列)は値の CSV に平坦化する。
      class KeeperMapper
        def to_row(keeper)
          {
            id: keeper.id.to_s,
            name: keeper.name,
            specialties: keeper.specialties.map { |taxon_class| taxon_class.value }.join(',')
          }
        end

        def to_aggregate(row)
          Domain::Staff::Keeper.reconstitute(
            id: Domain::Shared::Identifier.new(row['id']),
            name: row['name'],
            specialties: parse_specialties(row['specialties'])
          )
        end

        private

        def parse_specialties(value)
          value.to_s.split(',').reject(&:empty?).map { |key| Domain::Taxonomy::TaxonClass.new(key) }
        end
      end
    end
  end
end
