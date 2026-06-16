# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      module CohabitationPolicy
        module_function

        def compatible?(resident_species, newcomer_species)
          incompatibility_reason(resident_species, newcomer_species).nil?
        end

        def incompatibility_reason(resident, newcomer)
          return "#{resident.name_ja}と#{newcomer.name_ja}は適温域が両立しません" unless resident.climate_overlaps?(newcomer)

          if resident.same_species?(newcomer)
            return "#{resident.name_ja}は単独性のため同種を同居させられません" if resident.solitary?

            return nil
          end

          if resident.predatory? || newcomer.predatory?
            return "#{resident.name_ja}と#{newcomer.name_ja}は捕食関係の恐れがあり同居させられません"
          end

          nil
        end
      end
    end
  end
end
