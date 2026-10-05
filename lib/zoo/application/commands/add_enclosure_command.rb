# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AddEnclosureCommand = Data.define(:name, :celsius, :capacity, :climate_controlled, :enclosures, :zoo, :unit_of_work) do
        def initialize(name:, celsius:, capacity:, climate_controlled: false, enclosures: nil, zoo: nil, unit_of_work: nil)
          raise ArgumentError, 'name は必須です' if name.nil?
          raise ArgumentError, 'celsius は必須です' if celsius.nil?
          raise ArgumentError, 'capacity は必須です' if capacity.nil?

          super(name:, celsius:, capacity:, climate_controlled: climate_controlled == true, enclosures:, zoo:,
                unit_of_work:)
        end

        def bind(enclosures:, zoo:, unit_of_work:, **)
          with(enclosures:, zoo:, unit_of_work:)
        end
      end
    end
  end
end
