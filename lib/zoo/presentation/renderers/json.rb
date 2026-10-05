# frozen_string_literal: true

module Zoo
  module Presentation
    module Renderers
      module Json
        module_function

        def render(result)
          return failure(result.error) if result.failure?

          views.fetch(result.service).call(result.value)
        end

        def views
          s = Serializer
          a = AnimalSerializer
          {
            acquire_animal: ->(profile) { [201, a.animal(profile)] },
            add_enclosure: ->(profile) { [201, s.enclosure(profile)] },
            admit_visitors: ->(revenue) { [200, { revenue: revenue.yen }] },
            assign_keeper: ->(profile) { [200, s.enclosure(profile)] },
            clean_enclosure: ->(profile) { [200, s.enclosure(profile)] },
            discharge_keeper: ->(profile) { [200, s.enclosure(profile)] },
            enrich_enclosure: ->(profile) { [200, s.enclosure(profile)] },
            examine_animal: ->(report) { [200, { animal_id: report.animal_id, result: report.diagnosis.to_s }] },
            feed_animal: ->(profile) { [200, a.animal(profile)] },
            hire_keeper: ->(summary) { [201, s.keeper(summary)] },
            hire_veterinarian: ->(summary) { [201, s.veterinarian(summary)] },
            house_animal: ->(profile) { [200, s.enclosure(profile)] },
            make_rounds: ->(report) { [200, s.rounds_report(report)] },
            operate_day: ->(operating) { [200, s.day_report(operating)] },
            release_animal: ->(profile) { [200, a.animal(profile)] },
            rename_animal: ->(profile) { [200, a.animal(profile)] },
            run_days: ->(summary) { [200, s.run_days_summary(summary)] },
            set_admission_fee: ->(fee) { [200, { admission_fee: fee.yen }] },
            transfer_animal: ->(profile) { [200, a.animal(profile)] },
            treat_animal: ->(profile) { [200, a.animal(profile)] },
            animal_detail: ->(profile) { [200, a.animal(profile)] },
            alert_list: ->(alerts) { [200, alerts.map { |alert| s.alert(alert) }] },
            checklist: ->(chores) { [200, chores.map { |chore| s.chore(chore) }] },
            animal_list: ->(summaries) { [200, summaries.map { |summary| a.animal_summary(summary) }] },
            animal_prognosis: ->(outlook) { [200, a.animal_outlook(outlook)] },
            deceased_list: ->(records) { [200, records.map { |record| s.deceased(record) }] },
            enclosure_detail: ->(profile) { [200, s.enclosure(profile)] },
            enclosure_list: ->(profiles) { [200, profiles.map { |profile| s.enclosure(profile) }] },
            operating_history: ->(summaries) { [200, summaries.map { |summary| s.operating_summary(summary) }] },
            keeper_list: ->(summaries) { [200, summaries.map { |summary| s.keeper(summary) }] },
            threatened_species: ->(records) { [200, records.map { |record| s.exhibited_species(record) }] },
            veterinarian_list: ->(summaries) { [200, summaries.map { |summary| s.veterinarian(summary) }] },
            zoo_report: ->(stats) { [200, s.zoo_statistics(stats)] },
            species_list: ->(catalog) { [200, catalog.map { |code, species| s.species_ref(code, species) }] },
            food_list: ->(catalog) { [200, catalog.map { |code, food| s.food_ref(code, food) }] },
            taxon_class_list: ->(classes) { [200, classes.map { |taxon| s.taxon_class_ref(taxon.value, taxon) }] }
          }
        end

        def failure(error)
          [status_of(error), { error: { code: error.class.name.split('::').last, message: error.message } }]
        end

        def status_of(error)
          case error
          when Application::Errors::ApplicationError then 404
          when Domain::Errors::DomainError then 422
          end
        end
      end
    end
  end
end
