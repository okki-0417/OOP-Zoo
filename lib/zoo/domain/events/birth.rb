# frozen_string_literal: true

module Zoo
  module Domain
    module Events
      class Birth
        attr_reader :offspring, :sire_id, :dam_id, :occurred_on, :season

        def initialize(offspring:, sire_id:, dam_id:, occurred_on:, season:)
          @offspring = offspring
          @sire_id = sire_id
          @dam_id = dam_id
          @occurred_on = occurred_on
          @season = season
          freeze
        end

        def to_s
          "#{@offspring.species.name_ja}「#{@offspring.name}」が誕生しました"
        end
      end
    end
  end
end
