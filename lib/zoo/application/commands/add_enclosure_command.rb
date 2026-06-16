# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AddEnclosureCommand = Data.define(:name, :temperature, :capacity) do
        def initialize(name:, temperature:, capacity:)
          raise ArgumentError, 'name は必須です' if name.nil?
          raise ArgumentError, 'temperature は必須です' if temperature.nil?
          raise ArgumentError, 'capacity は必須です' if capacity.nil?

          super
        end
      end
    end
  end
end
