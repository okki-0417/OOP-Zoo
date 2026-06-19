# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Food do
      it '未知のカテゴリはエラーになること' do
        expect { described_class.new(name_ja: '謎肉', category: :unknown, satiety: 10) }
          .to raise_error(ArgumentError)
      end

      it '満腹度が0以下はエラーになること' do
        expect { described_class.new(name_ja: '空気', category: :meat, satiety: 0) }
          .to raise_error(ArgumentError)
      end
    end

    RSpec.describe FoodCatalog do
      it '全カテゴリの餌を網羅していること' do
        categories = described_class.all.map(&:category).uniq
        expect(categories).to contain_exactly(:meat, :fish, :insect, :plant, :fruit, :seed)
      end

      describe '.find' do
        it "既知のキー 'hay' を渡すと対応する Food を返すこと" do
          expect(described_class.find('hay')).to eq(described_class.hay)
        end

        it "未知のキー 'pizza' を渡すと nil を返すこと" do
          expect(described_class.find('pizza')).to be_nil
        end
      end
    end

    RSpec.describe 'Animal#eat' do
      let(:lion) { build_adult(SpeciesCatalog.lion) }
      let(:zebra) { build_adult(SpeciesCatalog.grevys_zebra) }

      before { lion.get_hungrier(50) }

      it '食性に合う餌を食べると空腹が満たされること' do
        expect { lion.eat(FoodCatalog.horse_meat) }
          .to change { lion.hunger_level }.by(-35)
      end

      it '肉食動物に草を与えられないこと' do
        expect { lion.eat(FoodCatalog.hay) }.to raise_error(Errors::IncompatibleFood)
      end

      it '草食動物に肉を与えられないこと' do
        expect { zebra.eat(FoodCatalog.horse_meat) }.to raise_error(Errors::IncompatibleFood)
      end

      it '雑食動物は肉も植物も食べられること' do
        macaque = build_adult(SpeciesCatalog.japanese_macaque)
        expect { macaque.eat(FoodCatalog.banana) }.not_to raise_error
        expect { macaque.eat(FoodCatalog.chicken) }.not_to raise_error
      end

      it '死んだ動物には給餌できないこと' do
        lion.die
        expect { lion.eat(FoodCatalog.horse_meat) }.to raise_error(Errors::DeadAnimal)
      end
    end
  end
end
