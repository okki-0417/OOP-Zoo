# frozen_string_literal: true

module Services
  class MakeRounds
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:make_rounds) do
        ApplicationRecord.transaction do
          keeper = ::Keeper.find_by(id: @command.keeper_id)
          raise Errors::KeeperNotFound, "飼育員 #{@command.keeper_id} は存在しません" if keeper.nil?

          reports = keeper.enclosures.map { |enclosure| round(keeper, enclosure) }
          persist(keeper, reports)
          { keeper:, reports: }
        end
      end
    end

    private

    def round(keeper, enclosure)
      ::Rounding.new(keeper:, occupancy: ::Occupancy.of(enclosure), foods: ::FoodCatalog.all).perform
    end

    def persist(keeper, reports)
      reports.each do |report|
        report.enclosure.save!
        report.fed.each(&:save!)
      end
      keeper.save!
    end
  end
end
