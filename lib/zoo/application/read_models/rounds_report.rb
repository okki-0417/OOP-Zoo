# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      RoundsReport = Data.define(:keeper_id, :keeper_name, :remaining_minutes, :rounds) do
        def self.of(keeper, reports)
          new(
            keeper_id: keeper.id.to_s,
            keeper_name: keeper.name,
            remaining_minutes: keeper.remaining_minutes,
            rounds: reports.map do |report|
              {
                enclosure: StaffRef.of(report.enclosure),
                fed: report.fed.map(&:name),
                skipped: report.skipped.map { |subject, reason| { subject:, reason: } },
                cleaned: report.cleaned?,
                enriched: report.enriched?
              }
            end
          )
        end
      end
    end
  end
end
