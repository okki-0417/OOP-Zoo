# frozen_string_literal: true

module Zoo
  module Domain
    module Events
      class AnimalConceived
        attr_reader :dam, :sire_id, :sex, :inbreeding_coefficient, :keeper_id, :occurred_on, :season

        def initialize(dam:, sire_id:, sex:, inbreeding_coefficient:, keeper_id:, occurred_on:, season:)
          @dam = dam
          @sire_id = sire_id
          @sex = sex
          @inbreeding_coefficient = inbreeding_coefficient
          @keeper_id = keeper_id
          @occurred_on = occurred_on
          @season = season
          freeze
        end

        def to_s
          "#{@dam.species.name_ja}「#{@dam.name}」が#{@sex.label}の子を妊娠しました"
        end
      end
    end
  end
end
