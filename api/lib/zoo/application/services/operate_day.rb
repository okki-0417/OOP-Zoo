# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class OperateDay
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:operate_day) do
            ApplicationRecord.transaction do
              zoo_day = Domain::ZooDay.new(
                zoo: Domain::Zoo.current,
                occupancies: Domain::Occupancy.all,
                keepers: Domain::Keeper.order(:id).to_a,
                veterinarians: Domain::Veterinarian.order(:id).to_a,
                yesterday: Domain::Operating.latest,
                random: @command.random
              )

              operating = zoo_day.run

              operating.save!
              zoo_day.enclosures.each(&:save!)
              zoo_day.on_exhibit.each(&:save!)
              zoo_day.keepers.each(&:save!)
              zoo_day.zoo.save!

              operating
            end
          end
        end
      end
    end
  end
end
