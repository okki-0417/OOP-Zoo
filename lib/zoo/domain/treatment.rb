# frozen_string_literal: true

module Zoo
  module Domain
    class Treatment
      HEAL_AMOUNT = 50

      def initialize(veterinarian:, animal:)
        @veterinarian = veterinarian
        @animal = animal
      end

      def perform
        raise Errors::DeadAnimal, "#{@animal.name}は既に死亡しています" if @animal.dead?

        @animal.recover if @animal.sick?
        @animal.heal(HEAL_AMOUNT)
        self
      end

      def to_s
        "#{@veterinarian.name}が#{@animal.name}を治療"
      end
    end
  end
end
