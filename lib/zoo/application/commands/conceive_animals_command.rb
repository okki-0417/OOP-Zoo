# frozen_string_literal: true

module Zoo
  module Application
    module Commands
      ConceiveAnimalsCommand = Data.define(:sire_id, :dam_id, :keeper_id) do
        def initialize(sire_id:, dam_id:, keeper_id: nil)
          raise ArgumentError, 'sire_id は必須です' if sire_id.nil?
          raise ArgumentError, 'dam_id は必須です' if dam_id.nil?

          super
        end
      end
    end
  end
end
