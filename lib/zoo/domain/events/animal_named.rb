# frozen_string_literal: true

module Zoo
  module Domain
    module Events
      class AnimalNamed
        attr_reader :animal, :name, :keeper_id, :occurred_on

        def initialize(animal:, name:, keeper_id:, occurred_on:)
          @animal = animal
          @name = name
          @keeper_id = keeper_id
          @occurred_on = occurred_on
          freeze
        end

        def to_s
          "#{@animal.species_name}が「#{@name}」と名付けられました"
        end
      end
    end
  end
end
