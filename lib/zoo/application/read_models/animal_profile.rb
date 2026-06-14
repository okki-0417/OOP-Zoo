# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      AnimalProfile = Data.define(
        :id, :name, :species, :taxon_class, :diet, :conservation_code, :conservation_label,
        :sex, :life_stage, :age_in_days, :health, :max_health, :weak,
        :hunger, :starving, :illness, :alive, :cause, :parents,
        :enclosure_id, :enclosure_name
      )
    end
  end
end
