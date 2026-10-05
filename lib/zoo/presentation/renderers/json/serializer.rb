# frozen_string_literal: true

module Zoo
  module Presentation
    module Renderers
      module Json
        module Serializer
          module_function

          def ref(member)
            { id: member.id.to_s, name: member.name }
          end

          def alert(severity:, kind:, subject_type:, subject:, message:)
            {
              severity: severity.to_s, kind: kind.to_s,
              subject: { type: subject_type.to_s, id: subject_type == :zoo ? nil : subject.id.to_s, name: subject.name },
              message: message
            }
          end

          def chore(kind:, label:, items:)
            {
              kind: kind.to_s, label: label, done_count: items.count { |item| item[:done] }, total: items.size,
              items: items.map do |item|
                { subject: { type: item[:type].to_s, **ref(item[:subject]) }, done: item[:done] }
              end
            }
          end

          def enclosure(enclosure:, occupants:, keepers:)
            {
              id: enclosure.id.to_s, name: enclosure.name, celsius: enclosure.temperature.celsius,
              climate_controlled: enclosure.climate_controlled?,
              capacity: enclosure.capacity, population: occupants.size,
              cleanliness: enclosure.cleanliness_level, filthy: enclosure.filthy?,
              enrichment: enclosure.enrichment.level, barren: enclosure.barren?,
              keepers: keepers.map { |keeper| ref(keeper) },
              occupants: occupants.map { |animal| AnimalSerializer.animal_summary(animal) }
            }
          end

          def keeper(keeper:, enclosures:)
            {
              id: keeper.id.to_s, name: keeper.name, specialties: keeper.specialties_label,
              worked_minutes: keeper.worked_minutes, remaining_minutes: keeper.remaining_minutes,
              enclosures: enclosures.map { |enclosure| ref(enclosure) }
            }
          end

          def rounds_report(keeper:, reports:)
            {
              keeper_id: keeper.id.to_s, keeper_name: keeper.name,
              remaining_minutes: keeper.remaining_minutes,
              rounds: reports.map do |report|
                {
                  enclosure: ref(report.enclosure),
                  fed: report.fed.map(&:name),
                  skipped: report.skipped.map { |subject, reason| { subject:, reason: } },
                  cleaned: report.cleaned?,
                  enriched: report.enriched?
                }
              end
            }
          end

          def veterinarian(veterinarian)
            ref(veterinarian)
          end

          def deceased(animal)
            { name: animal.name, species: animal.species_name, cause: animal.cause_of_death_label }
          end

          def exhibited_species(species:, count:)
            status = species.conservation_status
            { name_ja: species.name_ja, status_code: status.code, status_label: status.label, count: count }
          end

          def day_report(operating)
            {
              visitors: operating.visitors, income: operating.income.yen, cost: operating.cost.yen,
              deaths: operating.deaths, balance: operating.balance.yen, reputation: operating.reputation,
              bankrupt: operating.balance.negative?, outbreak: operating.outbreak
            }
          end

          def operating_summary(operating)
            {
              day: operating.day, visitors: operating.visitors, income: operating.income.yen, cost: operating.cost.yen,
              net_income: operating.net_income.yen, deaths: operating.deaths, balance: operating.balance.yen,
              reputation: operating.reputation, outbreak: operating.outbreak
            }
          end

          def run_days_summary(days:, total_deaths:, deaths_by_cause:)
            { days:, total_deaths:, deaths_by_cause: }
          end

          def zoo_statistics(zoo:, population:, species_count:, threatened_count:, births:, deaths_by_cause:)
            {
              population:, species_count:, threatened_count:, births:, deaths_by_cause:,
              revenue: zoo.revenue.yen, balance: zoo.balance.yen, reputation: zoo.reputation_score
            }
          end

          def species_ref(key, species)
            {
              key: key.to_s, name_ja: species.name_ja, taxon_class: species.taxon_label,
              diet: species.diet_label, conservation_code: species.conservation_code,
              conservation_label: species.conservation_label
            }
          end

          def food_ref(key, food)
            { key: key.to_s, name_ja: food.name_ja, category: food.category.to_s, satiety: food.satiety }
          end

          def taxon_class_ref(key, taxon_class)
            { key: key.to_s, label: taxon_class.label }
          end
        end
      end
    end
  end
end
