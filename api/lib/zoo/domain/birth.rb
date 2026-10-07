# frozen_string_literal: true

module Zoo
  module Domain
    class Birth
      NEWBORN_HEALTH = 50

      attr_reader :sire, :dam, :offspring

      def initialize(sire:, dam:, name: nil, max_health: NEWBORN_HEALTH)
        @sire = sire
        @dam = dam
        @name = name
        @max_health = max_health
        @offspring = nil
      end

      def parents
        [@sire, @dam].compact
      end

      def deliver
        sex = @dam.expected_offspring_sex
        inbreeding = @dam.expected_offspring_inbreeding
        @dam.deliver
        @offspring = build_offspring(@name || default_name, sex, inbreeding)
        self
      end

      def deliver_litter
        inbreeding = @dam.expected_offspring_inbreeding
        @dam.deliver
        @offspring = Array.new(@dam.litter_size) do |i|
          build_offspring("#{@name}#{i + 1}", Animal::Sex.random, inbreeding)
        end
        self
      end

      def to_s
        Array(@offspring).map { |o| "#{o.species_name}「#{o.name}」が誕生しました" }.join("\n")
      end

      private

      def build_offspring(name, sex, inbreeding)
        Animal.new(
          species: @dam.species, name: name, sex: sex,
          max_health: newborn_vitality(@max_health, inbreeding),
          age_in_days: 0, sire: @sire, dam: @dam
        )
      end

      def default_name
        "#{@dam.species_name}の赤ちゃん"
      end

      def newborn_vitality(base, inbreeding)
        (base * (1.0 - inbreeding)).round.clamp(1, base)
      end
    end
  end
end
