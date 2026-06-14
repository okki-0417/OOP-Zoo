# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      BreedAnimalsCommand = Data.define(:sire_id, :dam_id, :enclosure_id, :name, :sex) do
        def initialize(sire_id:, dam_id:, enclosure_id:, name:, sex:)
          raise ArgumentError, 'sire_id は必須です' if sire_id.nil?
          raise ArgumentError, 'dam_id は必須です' if dam_id.nil?
          raise ArgumentError, 'enclosure_id は必須です' if enclosure_id.nil?
          raise ArgumentError, 'name は必須です' if name.nil?
          raise ArgumentError, 'sex は必須です' if sex.nil?

          super(sire_id: sire_id, dam_id: dam_id, enclosure_id: enclosure_id, name: name, sex: sex)
        end
      end
    end
  end
end
