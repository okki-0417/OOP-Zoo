# frozen_string_literal: true

module Zoo
  module Domain
    module Events
      # 個体が誕生したことを表すドメインイベント。
      class AnimalBorn
        attr_reader :animal, :sire_id, :dam_id

        def initialize(animal:, sire_id:, dam_id:)
          @animal = animal
          @sire_id = sire_id
          @dam_id = dam_id
          freeze
        end

        def to_s
          "#{@animal.species.name_ja}「#{@animal.name}」が誕生しました"
        end
      end
    end
  end
end
