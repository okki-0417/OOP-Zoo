# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      AnimalOutlook = Data.define(:animal_id, :housed, :outlook, :days_to_death, :cause_of_death) do
        def self.of(animal, prognosis)
          new(
            animal_id: animal.id.to_s,
            housed: true,
            outlook: prognosis.outlook,
            days_to_death: prognosis.days_to_death,
            cause_of_death: prognosis.cause_of_death_label
          )
        end

        def self.unhoused(animal)
          new(animal_id: animal.id.to_s, housed: false, outlook: nil, days_to_death: nil, cause_of_death: nil)
        end
      end
    end
  end
end
