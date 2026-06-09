# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      attr_reader :species, :current_health, :name

      CRY_OUT_DAMAGE = 1

      def initialize(species:, name:, voice:, max_health:)
        @species = species
        @name = name
        @voice = voice
        @max_health = max_health
        @current_health = max_health
      end

      def cry_out
        current_voice.tap { decrease_health(CRY_OUT_DAMAGE) }
      end

      def current_voice
        return '...' if dying? || @voice.to_s.empty?

        weak? ? "#{@voice}..." : @voice
      end

      def change_voice(new_voice)
        raise ArgumentError, '鳴き声はnilにできません' if new_voice.nil?

        @voice = new_voice
      end

      def heal(amount)
        raise ArgumentError, '回復量は0以上でなければなりません' if amount.negative?

        @current_health += amount
        @current_health = @max_health if @current_health > @max_health

        @current_health
      end

      def change_name(new_name)
        raise ArgumentError, '名前は一文字以上でなければなりません' if new_name.to_s.empty?

        @name = new_name
      end

      private

      def decrease_health(amount)
        @current_health -= amount
        @current_health = 0 if @current_health.negative?
      end

      def weak?
        @current_health <= @max_health * 0.2
      end

      def dying?
        @current_health.zero?
      end
    end
  end
end
