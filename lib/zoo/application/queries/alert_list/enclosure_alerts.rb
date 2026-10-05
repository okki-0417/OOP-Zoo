# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class AlertList
        class EnclosureAlerts
          def initialize(occupancy:)
            @occupancy = occupancy
          end

          def to_a
            enclosure = @occupancy.enclosure
            [
              (alert(:warning, :filthy, '不潔です。同居する動物に寄生虫がまん延します') if enclosure.filthy?),
              (alert(:warning, :overcrowded, '過密です。ストレスと闘争が増えます') if @occupancy.overcrowded?),
              (alert(:notice, :barren, '刺激が乏しく、動物が退屈しています') if enclosure.barren?)
            ].compact
          end

          private

          def alert(severity, kind, message)
            ReadModels::Alert.about_enclosure(@occupancy.enclosure, severity:, kind:, message:)
          end
        end
      end
    end
  end
end
