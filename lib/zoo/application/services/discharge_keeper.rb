# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class DischargeKeeper
        def initialize(keepers:, enclosures:, tendings:, unit_of_work:)
          @keepers = keepers
          @enclosures = enclosures
          @tendings = tendings
          @unit_of_work = unit_of_work
        end

        def call(command)
          @unit_of_work.run do
            keeper = @keepers.find(command.keeper_id)
            raise Errors::KeeperNotFound, "飼育員 #{command.keeper_id} は存在しません" if keeper.nil?

            enclosure = @enclosures.find(command.enclosure_id)
            raise Errors::EnclosureNotFound, "エリア #{command.enclosure_id} は存在しません" if enclosure.nil?

            @tendings.save(Domain::Relieving.of(current_tending!(keeper, enclosure)))
          end
        end

        private

        def current_tending!(keeper, enclosure)
          @tendings.tending_of(keeper, enclosure) ||
            raise(Errors::TendingNotFound, "#{keeper.name}は#{enclosure.name}を担当していません")
        end
      end
    end
  end
end
