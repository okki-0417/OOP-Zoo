# frozen_string_literal: true

module Zoo
  module Domain
    class Birth
      include Shared::Entity

      NEWBORN_HEALTH = 50

      attr_reader :id, :sire, :dam, :offspring, :occurred_on, :season

      def initialize(sire:, dam:, occurred_on: 0, season: Season.spring, name: nil,
                     max_health: NEWBORN_HEALTH, keeper_id: nil, id: Shared::Identifier.new)
        @id = id
        @sire = sire
        @dam = dam
        @occurred_on = occurred_on
        @season = season
        @name = name
        @max_health = max_health
        @keeper_id = keeper_id
        @offspring = nil
      end

      def self.reconstitute(id:, sire:, dam:, offspring:, occurred_on:, season:)
        allocate.tap do |birth|
          birth.instance_variable_set(:@id, id)
          birth.instance_variable_set(:@sire, sire)
          birth.instance_variable_set(:@dam, dam)
          birth.instance_variable_set(:@offspring, offspring)
          birth.instance_variable_set(:@occurred_on, occurred_on)
          birth.instance_variable_set(:@season, season)
        end
      end

      def parents
        [@sire, @dam].compact
      end

      def deliver
        sex = @dam.expected_offspring_sex
        inbreeding = @dam.expected_offspring_inbreeding
        @dam.deliver
        @offspring = build_offspring(@name || default_name, sex, inbreeding)
        @dam.record_event(self)
        self
      end

      def deliver_litter
        inbreeding = @dam.expected_offspring_inbreeding
        @dam.deliver
        @offspring = Array.new(@dam.litter_size) do |i|
          build_offspring("#{@name}#{i + 1}", Animal::Sex.random, inbreeding)
        end
        @dam.record_event(self)
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
          age_in_days: 0, sire_id: @sire.id, dam_id: @dam.id
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
