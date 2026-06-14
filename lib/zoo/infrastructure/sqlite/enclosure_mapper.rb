# frozen_string_literal: true

module Zoo
  module Infrastructure
    module Sqlite
      # Enclosure 集約 ⇄ 行。occupants は id の CSV で持ち(子は animals テーブル)、
      # 復元時は呼び手(EnclosureRepository)が解決した occupants を渡す。
      class EnclosureMapper
        def to_row(enclosure)
          {
            id: enclosure.id.to_s,
            name: enclosure.name,
            celsius: enclosure.temperature.celsius,
            capacity: enclosure.capacity,
            cleanliness: enclosure.cleanliness.level,
            occupant_ids: enclosure.occupants.map { |animal| animal.id.to_s }.join(',')
          }
        end

        def to_aggregate(row, occupants)
          Domain::Husbandry::Enclosure.reconstitute(
            id: Domain::Shared::Identifier.new(row['id']),
            name: row['name'],
            temperature: Domain::Shared::Temperature.celsius(row['celsius']),
            capacity: row['capacity'],
            cleanliness: Domain::Husbandry::Cleanliness.new(row['cleanliness']),
            occupants: occupants
          )
        end

        # 行に保存された occupant の id 一覧。
        def occupant_ids(row)
          row['occupant_ids'].to_s.split(',').reject(&:empty?)
        end
      end
    end
  end
end
