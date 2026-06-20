# frozen_string_literal: true

module Zoo
  module Domain
    class Birth
      include Shared::Entity

      NEWBORN_HEALTH = 50

      attr_reader :id, :sire, :dam, :offspring, :day, :season

      def initialize(sire:, dam:, day: 0, season: Season.spring, name: nil,
                     max_health: NEWBORN_HEALTH, keeper_id: nil, id: Shared::Identifier.new)
        @id = id
        @sire = sire
        @dam = dam
        @day = day
        @season = season
        @name = name
        @max_health = max_health
        @keeper_id = keeper_id
        @offspring = nil
      end

      def self.reconstitute(id:, sire:, dam:, offspring:, day:, season:)
        allocate.tap do |birth|
          birth.instance_variable_set(:@id, id)
          birth.instance_variable_set(:@sire, sire)
          birth.instance_variable_set(:@dam, dam)
          birth.instance_variable_set(:@offspring, offspring)
          birth.instance_variable_set(:@day, day)
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
        record_birth(@offspring)
        self
      end

      def deliver_litter
        inbreeding = @dam.expected_offspring_inbreeding
        @dam.deliver
        @offspring = Array.new(@dam.litter_size) do |i|
          build_offspring("#{@name}#{i + 1}", Animal::Sex.random, inbreeding)
        end
        @offspring.each { |o| record_birth(o) }
        self
      end

      private

      def build_offspring(name, sex, inbreeding)
        Animal.new(
          species: @dam.species, name: name, sex: sex,
          max_health: newborn_vitality(@max_health, inbreeding),
          age_in_days: 0, sire_id: @sire.id, dam_id: @dam.id
        )
      end

      def record_birth(offspring)
        @dam.record_event(Events::Birth.new(
                            offspring: offspring, sire_id: @sire.id, dam_id: @dam.id,
                            occurred_on: @day, season: @season, keeper_id: @keeper_id
                          ))
      end

      def default_name
        "#{@dam.species.name_ja}の赤ちゃん"
      end

      def newborn_vitality(base, inbreeding)
        (base * (1.0 - inbreeding)).round.clamp(1, base)
      end
    end
  end
end
