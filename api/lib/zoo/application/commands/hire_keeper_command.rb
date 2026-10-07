# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      HireKeeperCommand = Data.define(:name, :specialties) do
        def initialize(name:, specialties:)
          raise ArgumentError, 'name は必須です' if name.nil?
          raise ArgumentError, 'specialties は必須です' if specialties.nil?
          raise ArgumentError, 'specialties は配列で指定してください' unless specialties.is_a?(Array)

          super
        end
      end
    end
  end
end
