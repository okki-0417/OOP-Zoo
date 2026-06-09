# frozen_string_literal: true

module Zoo
  module Domain
    module Events
      # 個体が死亡したことを表すドメインイベント。
      class AnimalDied
        CAUSE_LABELS = {
          old_age: '老衰', starvation: '餓死', illness: '病死',
          predation: '捕食', unknown: '不明'
        }.freeze

        attr_reader :animal, :cause

        def initialize(animal:, cause:)
          @animal = animal
          @cause = cause
          freeze
        end

        def cause_label
          CAUSE_LABELS.fetch(@cause, @cause.to_s)
        end

        def to_s
          "#{@animal.species.name_ja}「#{@animal.name}」が#{cause_label}しました"
        end
      end
    end
  end
end
