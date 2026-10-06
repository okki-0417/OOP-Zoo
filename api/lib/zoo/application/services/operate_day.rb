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
            @command.unit_of_work.run do
              zoo = @command.zoo.load

              operating = Domain::Operating.new(
                zoo:,
                occupancies: @command.housings.all_occupancies,
                keepers: @command.keepers.all,
                veterinarians: @command.veterinarians.all,
                yesterday_operating: @command.operatings.latest,
                random: @command.random
              )

              operating.operate_day

              @command.operatings.save(operating)
              @command.enclosures.save_all(operating.enclosures)
              @command.animals.save_all(operating.on_exhibit)
              operating.keepers.each { |keeper| @command.keepers.save(keeper) }
              @command.zoo.save(operating.zoo)

              operating
            end
          end
        end
      end
    end
  end
end
