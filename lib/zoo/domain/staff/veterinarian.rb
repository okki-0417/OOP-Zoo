# frozen_string_literal: true

module Zoo
  module Domain
    module Staff
      # 獣医を表すエンティティ。動物の診察と治療を担う。
      class Veterinarian
        attr_reader :id, :name

        # 治療1回で回復する体力。
        TREATMENT_HEAL = 50

        def initialize(name:, id: Shared::Identifier.new)
          raise ArgumentError, '獣医名は必須です' if name.to_s.empty?

          @id = id
          @name = name
        end

        # 診察し、状態を示す記号を返す。
        #   :dead / :sick / :injured(衰弱) / :healthy
        def examine(animal)
          return :dead if animal.dead?
          return :sick if animal.sick?
          return :injured if animal.health.weak?

          :healthy
        end

        # 治療する。病気を治し、体力を回復させる。死亡個体は治療できない。
        def treat(animal)
          raise Errors::DeadAnimal, "#{animal.name}は既に死亡しています" if animal.dead?

          animal.recover if animal.sick?
          animal.heal(TREATMENT_HEAL)
          self
        end

        def to_s
          "獣医 #{@name}"
        end
      end
    end
  end
end
