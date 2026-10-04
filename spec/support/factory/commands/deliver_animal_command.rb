# frozen_string_literal: true

require_relative '../command_factory'

module Factory
  class DeliverAnimalCommand < CommandFactory
    target ::Zoo::Application::Commands::DeliverAnimalCommand

    defaults do |animals:, enclosures:, breedings:, **|
      lion = ::Zoo::Domain::SpeciesCatalog.lion
      sire, dam = build_pair(lion)
      breeding = ::Zoo::Domain::Breeding.new(sire:, dam:)
      breeding.conceive
      lion.gestation_period_days.times { dam.gestate }
      enclosure = build_enclosure
      animals.save(sire)
      animals.save(dam)
      breedings.save(breeding)
      enclosures.save(enclosure)

      { dam_id: dam.id, enclosure_id: enclosure.id }
    end
  end
end
