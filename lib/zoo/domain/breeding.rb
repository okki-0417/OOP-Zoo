# frozen_string_literal: true

module Zoo
  module Domain
    module Breeding
      module_function

      def conceive(sire:, dam:, animal_lookup:, day:, keeper: nil, season: Season.spring)
        error_messages = []
        error_messages << 'sireはオスでなければなりません' unless sire.male?
        error_messages << 'damはメスでなければなりません' unless dam.female?
        error_messages << '同種でなければ繁殖できません' unless sire.same_species?(dam)
        error_messages << '異性でなければ繁殖できません' unless sire.sex_opposite?(dam)
        error_messages << '成熟な個体同士でなければ繁殖できません' unless sire.fertile? && dam.fertile?
        error_messages << '健康な個体同士でなければ繁殖できません' unless sire.healthy? && dam.healthy?
        error_messages << '近親交配は避ける必要があります' if sire.related_to?(dam)
        error_messages << "#{dam.species.name_ja}は#{season.label}には繁殖しません" unless dam.breeds_in?(season)

        raise Errors::BreedingNotAllowed, error_messages.join(', ') unless error_messages.empty?

        inbreeding = kinship(dam, sire, animal_lookup)
        dam.conceive(
          sire_id: sire.id, inbreeding: inbreeding,
          keeper_id: keeper&.id, occurred_on: day, season: season
        )
        dam
      end

      def mean_kinship(animals, lookup)
        pairs = animals.combination(2).to_a
        return 0.0 if pairs.empty?

        pairs.sum { |a, b| kinship(a, b, lookup) } / pairs.size
      end

      def kinship(a, b, lookup)
        a.pedigree.kinship_with(b.pedigree, lookup)
      end

      class << self
        private :kinship
      end
    end
  end
end
