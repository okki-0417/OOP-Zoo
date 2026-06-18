# frozen_string_literal: true

module Zoo
  module Domain
    class BreedingPair
      include Events::Recorder

      NEWBORN_HEALTH = 50

      attr_reader :sire, :dam

      def initialize(sire:, dam:)
        raise Errors::BreedingNotAllowed, 'sireはオスでなければなりません' unless sire.sex.male?
        raise Errors::BreedingNotAllowed, 'damはメスでなければなりません' unless dam.sex.female?

        reason = BreedingPolicy.rejection_reason(sire, dam)
        raise Errors::BreedingNotAllowed, reason if reason

        @sire = sire
        @dam = dam
        @gestation_days = nil
        @miscarried = false
      end

      def species
        @dam.species
      end

      def mate(season: Season.spring)
        raise Errors::BreedingNotAllowed, '既に妊娠/抱卵中です' if expecting?
        unless species.breeds_in?(season)
          raise Errors::BreedingNotAllowed,
                "#{species.name_ja}は#{season.label}には繁殖しません"
        end

        @gestation_days = 0
        @miscarried = false
        self
      end

      def expecting?
        !@gestation_days.nil?
      end

      def advance(days = 1)
        return self unless expecting?
        return miscarry if pregnancy_failing?

        @gestation_days += days
        self
      end

      def miscarried?
        @miscarried
      end

      def ready_to_deliver?
        expecting? && @gestation_days >= species.gestation_period_days
      end

      def deliver(name:, sex:, max_health: NEWBORN_HEALTH, inbreeding: 0.0)
        raise Errors::BreedingNotAllowed, 'まだ出産/孵化の時期ではありません' unless ready_to_deliver?

        offspring = Animal.new(
          species: species, name: name, sex: sex, max_health: newborn_vitality(max_health, inbreeding),
          age_in_days: 0, sire: @sire, dam: @dam
        )
        @gestation_days = nil

        record_event(Events::AnimalBorn.new(animal: offspring, sire_id: @sire.id, dam_id: @dam.id))
        offspring
      end

      def deliver_litter(name:, max_health: NEWBORN_HEALTH, inbreeding: 0.0)
        raise Errors::BreedingNotAllowed, 'まだ出産/孵化の時期ではありません' unless ready_to_deliver?

        vitality = newborn_vitality(max_health, inbreeding)
        litter = Array.new(species.litter_size) do |i|
          Animal.new(
            species: species, name: "#{name}#{i + 1}",
            sex: i.even? ? Animal::Sex.male : Animal::Sex.female,
            max_health: vitality, age_in_days: 0, sire: @sire, dam: @dam
          )
        end
        @gestation_days = nil

        litter.each { |o| record_event(Events::AnimalBorn.new(animal: o, sire_id: @sire.id, dam_id: @dam.id)) }
        litter
      end

      def to_s
        "#{species.name_ja}の繁殖ペア(#{@sire.name}×#{@dam.name})"
      end

      private

      def pregnancy_failing?
        @dam.starving? || @dam.stress.severe? || @dam.malnourished?
      end

      def miscarry
        @gestation_days = nil
        @miscarried = true
        self
      end

      def newborn_vitality(base, inbreeding)
        (base * (1.0 - inbreeding)).round.clamp(1, base)
      end
    end
  end
end
