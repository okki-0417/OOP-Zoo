# frozen_string_literal: true

module Zoo
  module Domain
    class Spectacle
      SATURATION = 3_000

      def initialize(on_exhibit:, buzz: 0)
        @on_exhibit = on_exhibit
        @buzz = buzz
      end

      def value
        saturate(charisma_total) + @buzz
      end

      private

      def charisma_total
        @on_exhibit.map(&:species).uniq.sum(&:charisma)
      end

      def saturate(standing)
        SATURATION * standing / (standing + SATURATION).to_f
      end
    end
  end
end
