# frozen_string_literal: true

module Zoo
  module Presentation
    module Renderers
      module Json
        module Serializer
          module_function

          def alert(alert)
            {
              severity: alert.severity.to_s, kind: alert.kind.to_s,
              subject: { type: alert.subject_type.to_s, id: alert.subject_id, name: alert.subject_name },
              message: alert.message
            }
          end

          def enclosure_summary(summary)
            {
              id: summary.id, name: summary.name, population: summary.population, capacity: summary.capacity,
              cleanliness: summary.cleanliness, filthy: summary.filthy
            }
          end

          def enclosure(profile)
            {
              id: profile.id, name: profile.name, capacity: profile.capacity, population: profile.population,
              cleanliness: profile.cleanliness, filthy: profile.filthy,
              enrichment: profile.enrichment, barren: profile.barren,
              keepers: profile.keepers.map(&:to_h),
              occupants: profile.occupants.map { |o| AnimalSerializer.animal_summary(o) }
            }
          end

          def keeper(summary)
            {
              id: summary.id, name: summary.name, specialties: summary.specialties,
              worked_minutes: summary.worked_minutes, remaining_minutes: summary.remaining_minutes,
              enclosures: summary.enclosures.map(&:to_h)
            }
          end

          def rounds_report(report)
            {
              keeper_id: report.keeper_id, keeper_name: report.keeper_name,
              remaining_minutes: report.remaining_minutes,
              rounds: report.rounds.map { |round| round.merge(enclosure: round[:enclosure].to_h) }
            }
          end

          def veterinarian(summary)
            { id: summary.id, name: summary.name }
          end

          def deceased(record)
            { name: record.name, species: record.species, cause: record.cause }
          end

          def exhibited_species(record)
            {
              name_ja: record.name_ja, status_code: record.status_code,
              status_label: record.status_label, count: record.count
            }
          end

          def day_report(report)
            {
              visitors: report.visitors, income: report.income.yen, cost: report.cost.yen,
              deaths: report.deaths, balance: report.balance.yen, reputation: report.reputation,
              bankrupt: report.balance.negative?, outbreak: report.outbreak
            }
          end

          def operating_summary(summary)
            {
              day: summary.day, visitors: summary.visitors, income: summary.income.yen, cost: summary.cost.yen,
              net_income: summary.net_income.yen, deaths: summary.deaths, balance: summary.balance.yen,
              reputation: summary.reputation, outbreak: summary.outbreak
            }
          end

          def run_days_summary(summary)
            { days: summary.days, total_deaths: summary.total_deaths, deaths_by_cause: summary.deaths_by_cause }
          end

          def zoo_statistics(stats)
            {
              population: stats.population, species_count: stats.species_count,
              threatened_count: stats.threatened_count, births: stats.births,
              deaths_by_cause: stats.deaths_by_cause,
              revenue: stats.revenue.yen, balance: stats.balance.yen, reputation: stats.reputation
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
