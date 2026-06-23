# frozen_string_literal: true

module Zoo
  module Domain
    module Events
      class Birth
        attr_reader :offspring, :sire_id, :dam_id, :occurred_on, :season, :keeper_id

        def initialize(offspring:, sire_id:, dam_id:, occurred_on:, season:, keeper_id: nil)
          @offspring = offspring
          @sire_id = sire_id
          @dam_id = dam_id
          @occurred_on = occurred_on
          @season = season
          @keeper_id = keeper_id
          freeze
        end

        def to_s
          "#{@offspring.species_name}「#{@offspring.name}」が誕生しました"
        end
      end
    end
  end
end
