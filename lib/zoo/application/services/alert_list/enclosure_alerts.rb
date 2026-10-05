# frozen_string_literal: true

module Zoo
  module Application
    module Services
      class AlertList
        class EnclosureAlerts
          def initialize(occupancy:, keepers:)
            @occupancy = occupancy
            @keepers = keepers
          end

          def to_a
            enclosure = @occupancy.enclosure
            [
              (alert(:warning, :unassigned, '担当の飼育員がいません。日々の見回りが行われません') if unattended?),
              (alert(:warning, :filthy, '不潔です。同居する動物に寄生虫がまん延します') if enclosure.filthy?),
              (alert(:warning, :overcrowded, '過密です。ストレスと闘争が増えます') if @occupancy.overcrowded?),
              (alert(:notice, :barren, '刺激が乏しく、動物が退屈しています') if enclosure.barren?)
            ].compact
          end

          private

          def unattended?
            @keepers.empty? && @occupancy.any?(&:alive?)
          end

          def alert(severity, kind, message)
            { severity:, kind:, subject_type: :enclosure, subject: @occupancy.enclosure, message: }
          end
        end
      end
    end
  end
end
