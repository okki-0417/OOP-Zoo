# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AddEnclosureCommand = Data.define(:name, :celsius, :capacity, :climate_controlled) do
        def initialize(name:, celsius:, capacity:, climate_controlled: false)
          raise ArgumentError, 'name は必須です' if name.nil?
          raise ArgumentError, 'celsius は必須です' if celsius.nil?
          raise ArgumentError, 'capacity は必須です' if capacity.nil?

          super(name:, celsius:, capacity:, climate_controlled: climate_controlled == true)
        end
      end
    end
  end
end
