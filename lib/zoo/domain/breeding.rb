# frozen_string_literal: true

module Zoo
  module Domain
    module Breeding
      module_function

      def mate(sire:, dam:, name:, sex:, animal_lookup:, day:, season: Season.spring)
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

        dam.conceive(sire_id: sire.id)
        dam.gestate(dam.gestation_period_days)

        inbreeding = dam.inbreeding_of_offspring_with(sire, animal_lookup)
        dam.deliver(name:, sex:, inbreeding:, occurred_on: day, season:)
      end
    end
  end
end
