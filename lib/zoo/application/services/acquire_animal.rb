# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AcquireAnimal
        # 絶滅危惧種を繁殖プログラムで受け入れたときの保全貢献による評判上昇。
        CONSERVATION_REPUTATION_GAIN = 5

        def initialize(animals:, zoo:, unit_of_work:)
          @animals = animals
          @zoo = zoo
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            animal = Domain::Animal.new(
              species: command.species,
              name: command.name,
              sex: command.sex,
              max_health: command.max_health,
              age_in_days: command.age_in_days
            )

            acquire(command.species)
            @animals.save(animal)
            animal
          end
        end

        private

        # 取引可能な種は購入(課金)し、絶滅危惧種は繁殖プログラムを通じて
        # 移送・貸与で受け入れる(資金は不要・保全貢献で評判が高まる)。
        def acquire(species)
          zoo = @zoo.load
          if species.tradeable?
            zoo.purchase(Domain::Operations::Pricing.acquisition_price(species))
          else
            zoo.apply_reputation(zoo.reputation.gain(CONSERVATION_REPUTATION_GAIN))
          end
          @zoo.save(zoo)
        end
      end
    end
  end
end
