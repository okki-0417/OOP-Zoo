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
            acquire_animal: ->(view) { [201, a.animal(**view)] },
            add_enclosure: ->(view) { [201, s.enclosure(**view)] },
            admit_visitors: ->(revenue) { [200, { revenue: revenue.yen }] },
            assign_keeper: ->(view) { [200, s.enclosure(**view)] },
            clean_enclosure: ->(view) { [200, s.enclosure(**view)] },
            discharge_keeper: ->(view) { [200, s.enclosure(**view)] },
            enrich_enclosure: ->(view) { [200, s.enclosure(**view)] },
            examine_animal: ->(view) { [200, { animal_id: view[:animal].id.to_s, result: view[:diagnosis].to_s }] },
            feed_animal: ->(view) { [200, a.animal(**view)] },
            hire_keeper: ->(view) { [201, s.keeper(**view)] },
            hire_veterinarian: ->(veterinarian) { [201, s.veterinarian(veterinarian)] },
            house_animal: ->(view) { [200, s.enclosure(**view)] },
            make_rounds: ->(view) { [200, s.rounds_report(**view)] },
            operate_day: ->(operating) { [200, s.day_report(operating)] },
            release_animal: ->(view) { [200, a.animal(**view)] },
            rename_animal: ->(view) { [200, a.animal(**view)] },
            run_days: ->(view) { [200, s.run_days_summary(**view)] },
            set_admission_fee: ->(fee) { [200, { admission_fee: fee.yen }] },
            transfer_animal: ->(view) { [200, a.animal(**view)] },
            treat_animal: ->(view) { [200, a.animal(**view)] },
            animal_detail: ->(view) { [200, a.animal(**view)] },
            alert_list: ->(alerts) { [200, alerts.map { |alert| s.alert(**alert) }] },
            checklist: ->(chores) { [200, chores.map { |chore| s.chore(**chore) }] },
            animal_list: ->(animals) { [200, animals.map { |animal| a.animal_summary(animal) }] },
            animal_prognosis: ->(view) { [200, a.animal_outlook(**view)] },
            deceased_list: ->(animals) { [200, animals.map { |animal| s.deceased(animal) }] },
            enclosure_detail: ->(view) { [200, s.enclosure(**view)] },
            enclosure_list: ->(views) { [200, views.map { |view| s.enclosure(**view) }] },
            operating_history: ->(operatings) { [200, operatings.map { |operating| s.operating_summary(operating) }] },
            keeper_list: ->(views) { [200, views.map { |view| s.keeper(**view) }] },
            threatened_species: ->(views) { [200, views.map { |view| s.exhibited_species(**view) }] },
            veterinarian_list: ->(veterinarians) { [200, veterinarians.map { |veterinarian| s.veterinarian(veterinarian) }] },
            zoo_report: ->(view) { [200, s.zoo_statistics(**view)] },
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
