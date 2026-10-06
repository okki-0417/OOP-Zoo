# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      ConceiveAnimalsCommand = Data.define(:sire_id, :dam_id, :animals, :breedings, :births, :zoo, :unit_of_work) do
        def initialize(sire_id:, dam_id:, animals: nil, breedings: nil, births: nil, zoo: nil, unit_of_work: nil)
          raise ArgumentError, 'sire_id は必須です' if sire_id.nil?
          raise ArgumentError, 'dam_id は必須です' if dam_id.nil?

          super
        end

        def bind(animals:, breedings:, births:, zoo:, unit_of_work:, **)
          with(animals:, breedings:, births:, zoo:, unit_of_work:)
        end
      end
    end
  end
end
