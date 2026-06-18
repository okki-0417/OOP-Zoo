# frozen_string_literal: true

module Zoo
  module Domain
    module Pricing
      module_function

      ACQUISITION_BASE_YEN = 20_000
      RARITY_PER_RANK_YEN = 10_000
      WEIGHT_PER_KG_YEN = 50

      CONSTRUCTION_BASE_YEN = 30_000
      CONSTRUCTION_PER_SLOT_YEN = 10_000
      CLIMATE_CONTROL_SURCHARGE_YEN = 50_000

      KEEPER_SIGNING_FEE_YEN = 20_000
      VETERINARIAN_SIGNING_FEE_YEN = 30_000

      def acquisition_price(species)
        yen = ACQUISITION_BASE_YEN +
              (RARITY_PER_RANK_YEN * species.conservation_status.rank) +
              (WEIGHT_PER_KG_YEN * species.adult_weight.kilograms).round
        Shared::Money.yen(yen)
      end

      def enclosure_construction_cost(capacity:, climate_controlled: false)
        yen = CONSTRUCTION_BASE_YEN + (CONSTRUCTION_PER_SLOT_YEN * capacity)
        yen += CLIMATE_CONTROL_SURCHARGE_YEN if climate_controlled
        Shared::Money.yen(yen)
      end

      def keeper_signing_fee
        Shared::Money.yen(KEEPER_SIGNING_FEE_YEN)
      end

      def veterinarian_signing_fee
        Shared::Money.yen(VETERINARIAN_SIGNING_FEE_YEN)
      end
    end
  end
end
