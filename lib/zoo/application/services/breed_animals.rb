# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class BreedAnimals
        def initialize(animals:, enclosures:, event_dispatcher:, unit_of_work:)
          @animals = animals
          @enclosures = enclosures
          @event_dispatcher = event_dispatcher
          @unit_of_work = unit_of_work
        end

        def call(command)
          offspring, events = @unit_of_work.run do
            sire = @animals.find(command.sire_id)
            raise Errors::AnimalNotFound, "動物 #{command.sire_id} は存在しません" if sire.nil?

            dam = @animals.find(command.dam_id)
            raise Errors::AnimalNotFound, "動物 #{command.dam_id} は存在しません" if dam.nil?

            enclosure = @enclosures.find(command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{command.enclosure_id} は存在しません" if enclosure.nil?

            pair = Domain::Breeding::BreedingPair.new(sire: sire, dam: dam)
            pair.mate
            pair.advance(dam.species.gestation_period_days)
            # 血統(在籍する全個体)から子の近交係数を求め、近交弱勢を反映する。
            inbreeding = Domain::Breeding::Pedigree.inbreeding_of_offspring(sire, dam, animal_lookup)
            child = pair.deliver(name: command.name, sex: command.sex, inbreeding: inbreeding)

            @animals.save(child)
            enclosure.admit(child)
            @enclosures.save(enclosure)

            [child, pair.pull_events]
          end

          @event_dispatcher.publish(events)
          offspring
        end

        private

        # 祖先を id から辿るための参照(在籍記録＝全個体リポジトリ)。
        def animal_lookup
          ->(id) { @animals.find(id) }
        end
      end
    end
  end
end
