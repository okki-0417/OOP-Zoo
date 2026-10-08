# frozen_string_literal: true

module Mutations
  class AddEnclosure < BaseMutation
    type Types::Enclosure, null: false

    argument :name, String
    argument :celsius, Integer
    argument :capacity, Integer
    argument :climate_controlled, Boolean, required: false, default_value: false

    def resolve(name:, celsius:, capacity:, climate_controlled:)
      enclosure = Enclosure.new(name:, temperature: Temperature.celsius(celsius), capacity:, climate_controlled:)
      Constructing.new(zoo: Zoo.current, enclosure:).perform
    end
  end
end
