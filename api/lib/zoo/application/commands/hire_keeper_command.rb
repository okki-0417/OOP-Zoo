# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      HireKeeperCommand = Data.define(:name, :specialties, :keepers, :zoo, :unit_of_work) do
        def initialize(name:, specialties:, keepers: nil, zoo: nil, unit_of_work: nil)
          raise ArgumentError, 'name は必須です' if name.nil?
          raise ArgumentError, 'specialties は必須です' if specialties.nil?
          raise ArgumentError, 'specialties は配列で指定してください' unless specialties.is_a?(Array)

          super
        end

        def bind(keepers:, zoo:, unit_of_work:, **)
          with(keepers:, zoo:, unit_of_work:)
        end
      end
    end
  end
end
