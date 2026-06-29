# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class OperateDay
        def initialize(animals:, enclosures:, housings:, keepers:, veterinarians:, zoo:,
                       operatings:, unit_of_work:, random: Random.new)
          @animals       = animals
          @enclosures    = enclosures
          @housings      = housings
          @keepers       = keepers
          @veterinarians = veterinarians
          @zoo           = zoo
          @operatings    = operatings
          @unit_of_work  = unit_of_work
          @random        = random
        end

        def call
          @unit_of_work.run do
            zoo = @zoo.load

            operating = Domain::Operating.new(
              zoo:,
              occupancies: @housings.all_occupancies,
              keepers: @keepers.all,
              veterinarians: @veterinarians.all,
              yesterday_operating: @operatings.latest,
              random: @random
            )

            operating.operate_day

            @operatings.save(operating)
            @enclosures.save_all(operating.enclosures)
            @animals.save_all(operating.on_exhibit)
            @zoo.save(operating.zoo)

            operating
          end
        end
      end
    end
  end
end
