# frozen_string_literal: true

module Zoo
  module Domain
    module Events
      class AnimalRenamed
        attr_reader :animal, :old_name, :new_name

        def initialize(animal:, old_name:, new_name:)
          @animal = animal
          @old_name = old_name
          @new_name = new_name
          freeze
        end

        def to_s
          "「#{@old_name}」を「#{@new_name}」に改名しました"
        end
      end
    end
  end
end
