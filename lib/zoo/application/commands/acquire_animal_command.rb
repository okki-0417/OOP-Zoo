# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      AcquireAnimalCommand = Data.define(:species, :name, :sex, :max_health, :age_in_days) do
        def initialize(species:, name:, sex:, max_health:, age_in_days: 0)
          raise ArgumentError, 'species は必須です' if species.nil?
          raise ArgumentError, 'name は必須です' if name.nil?
          raise ArgumentError, 'sex は必須です' if sex.nil?
          raise ArgumentError, 'max_health は必須です' if max_health.nil?

          super
        end
      end
    end
  end
end
