# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      # 読み取りモデル/ドメイン値を JSON 化可能なプリミティブ(文字列・整数・真偽・配列)へ
      # 射影する唯一の場所。ここで定める形が HTTP の契約(= openapi.yaml / フロントの生成型)と
      # 一致する。金額は整数(円)で返し、整形はクライアントに委ねる。
      module Serializer
        module_function

        def animal_summary(summary)
          {
            id: summary.id, name: summary.name, species: summary.species, alive: summary.alive,
            health: summary.health, max_health: summary.max_health, ailing: summary.ailing
          }
        end

        def animal(profile)
          {
            id: profile.id, name: profile.name, species: profile.species,
            taxon_class: profile.taxon_class, diet: profile.diet,
            conservation_code: profile.conservation_code, conservation_label: profile.conservation_label,
            sex: profile.sex, life_stage: profile.life_stage, age_in_days: profile.age_in_days,
            health: profile.health, max_health: profile.max_health, weak: profile.weak,
            hunger: profile.hunger, starving: profile.starving, illness: profile.illness,
            alive: profile.alive, cause: profile.cause, parents: profile.parents,
            enclosure_id: profile.enclosure_id, enclosure_name: profile.enclosure_name
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
            occupants: profile.occupants.map { |o| animal_summary(o) }
          }
        end

        def keeper(summary)
          { id: summary.id, name: summary.name, specialties: summary.specialties }
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
            bankrupt: report.bankrupt, outbreak: report.outbreak
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
          status = species.conservation_status
          {
            key: key.to_s, name_ja: species.name_ja, taxon_class: species.taxon_class.label,
            diet: species.diet_type.label, conservation_code: status.code, conservation_label: status.label
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
