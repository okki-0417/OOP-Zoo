# frozen_string_literal: true

module Zoo
  module Domain
    module Staff
      class Veterinarian
        include Shared::Entity
        attr_reader :id, :name

        TREATMENT_HEAL = 50

        def initialize(name:, id: Shared::Identifier.new)
          raise ArgumentError, '獣医名は必須です' if name.to_s.empty?

          @id = id
          @name = name
        end

        def self.reconstitute(id:, name:)
          allocate.tap do |vet|
            vet.instance_variable_set(:@id, id)
            vet.instance_variable_set(:@name, name)
          end
        end

        def examine(animal)
          return :dead if animal.dead?
          return :sick if animal.sick?
          return :injured if animal.health.weak?

          :healthy
        end

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
