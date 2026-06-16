# frozen_string_literal: true

module Zoo
  module Domain
    module Feeding
      module FoodCatalog
        module_function

        def horse_meat
          Food.new(name_ja: '馬肉', category: :meat, satiety: 35)
        end

        def chicken
          Food.new(name_ja: '鶏肉', category: :meat, satiety: 30)
        end

        def horse_mackerel
          Food.new(name_ja: 'アジ', category: :fish, satiety: 30)
        end

        def sardine
          Food.new(name_ja: 'イワシ', category: :fish, satiety: 25)
        end

        def cricket
          Food.new(name_ja: 'コオロギ', category: :insect, satiety: 10)
        end

        def mealworm
          Food.new(name_ja: 'ミルワーム', category: :insect, satiety: 8)
        end

        def hay
          Food.new(name_ja: '干し草', category: :plant, satiety: 25)
        end

        def bamboo_leaf
          Food.new(name_ja: '笹', category: :plant, satiety: 20)
        end

        def leafy_vegetable
          Food.new(name_ja: '葉野菜', category: :plant, satiety: 20)
        end

        def banana
          Food.new(name_ja: 'バナナ', category: :fruit, satiety: 25)
        end

        def apple
          Food.new(name_ja: 'りんご', category: :fruit, satiety: 20)
        end

        def formula_pellet
          Food.new(name_ja: '配合飼料', category: :seed, satiety: 30)
        end

        KEYS = %i[
          horse_meat chicken horse_mackerel sardine cricket mealworm
          hay bamboo_leaf leafy_vegetable banana apple formula_pellet
        ].freeze

        def keys
          KEYS
        end

        def all
          KEYS.map { |name| public_send(name) }
        end

        def find(key)
          symbol = key.to_s.to_sym
          return nil unless KEYS.include?(symbol)

          public_send(symbol)
        end
      end
    end
  end
end
