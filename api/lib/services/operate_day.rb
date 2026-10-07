# frozen_string_literal: true

module Services
  class OperateDay
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:operate_day) do
        ApplicationRecord.transaction do
          zoo_day = ::ZooDay.new(
            zoo: ::Zoo.current,
            occupancies: ::Occupancy.all,
            keepers: ::Keeper.order(:id).to_a,
            veterinarians: ::Veterinarian.order(:id).to_a,
            yesterday: ::Operating.latest,
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
