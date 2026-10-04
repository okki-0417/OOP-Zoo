# frozen_string_literal: true

class Releasing < HousingEvent
  belongs_to :closes_housing, class_name: 'Housing'
  private :closes_housing=

  def self.release(housing:, occurred_on: 0, keeper_id: nil)
    releasing = new(occurred_on: occurred_on, keeper_id: keeper_id, animal_id: housing.animal_id)
    releasing.send(:closes_housing=, housing)
    releasing.save!
    releasing
  end

  def animal
    closes_housing.animal
  end

  def to_s
    "#{animal.name}を解放"
  end
end
