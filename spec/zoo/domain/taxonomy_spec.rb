# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe DietType do
      it '肉食は肉を受け入れ草を受け入れないこと' do
        expect(described_class.carnivore.accepts?(:meat)).to be(true)
        expect(described_class.carnivore.accepts?(:plant)).to be(false)
      end

      it '雑食は肉も植物も受け入れること' do
        expect(described_class.omnivore.accepts?(:meat)).to be(true)
        expect(described_class.omnivore.accepts?(:plant)).to be(true)
      end

      it '肉食・魚食は捕食性とみなされ、草食はそうでないこと' do
        expect(described_class.carnivore).to be_predatory
        expect(described_class.piscivore).to be_predatory
        expect(described_class.herbivore).not_to be_predatory
        expect(described_class.insectivore).not_to be_predatory
      end
    end

    RSpec.describe ConservationStatus do
      it '深刻度で比較できること' do
        expect(described_class.critically_endangered).to be > described_class.least_concern
        expect(described_class.endangered).to be > described_class.vulnerable
      end

      it '絶滅危惧・絶滅を判定できること' do
        expect(described_class.endangered).to be_threatened
        expect(described_class.least_concern).not_to be_threatened
        expect(described_class.extinct).to be_extinct
      end
    end

    RSpec.describe TaxonClass do
      it '哺乳類は恒温・胎生であること' do
        expect(described_class.mammal).to be_warm_blooded
        expect(described_class.mammal).to be_viviparous
      end

      it '鳥類・爬虫類は卵生であること' do
        expect(described_class.bird).to be_oviparous
        expect(described_class.reptile).to be_oviparous
      end

      it '魚類は変温であること' do
        expect(described_class.fish).to be_cold_blooded
      end
    end

    RSpec.describe Species do
      let(:lion) { SpeciesCatalog.lion }
      let(:zebra) { SpeciesCatalog.grevys_zebra }
      let(:polar_bear) { SpeciesCatalog.polar_bear }

      it '学名で同一性が決まること' do
        expect(SpeciesCatalog.lion).to eq(SpeciesCatalog.lion)
        expect(lion).not_to eq(zebra)
      end

      it '捕食性・群れ性を判定できること' do
        expect(lion).to be_predatory
        expect(lion).to be_group_living
        expect(zebra).not_to be_predatory
        expect(polar_bear).to be_solitary
      end

      it '体格と行動様式に応じた必要面積を返すこと(最小5m²)' do
        expect(lion.space_requirement_sqm).to eq(95)
        expect(SpeciesCatalog.hercules_beetle.space_requirement_sqm).to eq(5)
      end

      describe '#required_food_variety' do
        it '受け入れカテゴリが1つの肉食は1であること' do
          expect(lion.required_food_variety).to eq(1)
        end

        it '受け入れカテゴリが多い雑食でも上限2であること' do
          expect(SpeciesCatalog.japanese_macaque.required_food_variety).to eq(2)
        end
      end

      describe '#diet_satisfied_by?' do
        let(:foods) { FoodCatalog }

        it '必要カテゴリ数を満たせば true であること' do
          expect(lion.diet_satisfied_by?([foods.horse_meat])).to be(true)
        end

        it '必要カテゴリ数に届かなければ false であること' do
          expect(SpeciesCatalog.african_elephant.diet_satisfied_by?([foods.hay])).to be(false)
        end

        it '食性に合わない餌はカテゴリに数えないこと' do
          expect(SpeciesCatalog.african_elephant.diet_satisfied_by?([foods.hay, foods.horse_meat])).to be(false)
        end

        it '空の給餌は false であること' do
          expect(lion.diet_satisfied_by?([])).to be(false)
        end
      end

      describe '#daily_hunger' do
        it 'HUNGER_MIN..HUNGER_MAX にクランプされること' do
          expect(SpeciesCatalog.african_elephant.daily_hunger)
            .to be_between(described_class::HUNGER_MIN, described_class::HUNGER_MAX)
        end
      end

      describe '#satiety_from' do
        it '満腹度は最低1を返すこと' do
          expect(SpeciesCatalog.african_elephant.satiety_from(FoodCatalog.hay)).to be >= 1
        end
      end

      describe '#daily_food_cost' do
        it 'FOOD_COST_MIN_YEN を下回らない Money を返すこと' do
          cost = SpeciesCatalog.hercules_beetle.daily_food_cost
          expect(cost).to be_a(Shared::Money)
          expect(cost.yen).to be >= described_class::FOOD_COST_MIN_YEN
        end
      end
    end

    RSpec.describe SpeciesCatalog do
      it '全種が生成できること' do
        expect(described_class.all.size).to eq(15)
        expect(described_class.all).to all(be_a(Species))
      end

      it '6つの綱すべてを網羅していること' do
        classes = described_class.all.map { |s| s.taxon_class.value }.uniq
        expect(classes).to contain_exactly(:mammal, :bird, :reptile, :amphibian, :fish, :invertebrate)
      end

      it '6つの食性すべてを網羅していること' do
        diets = described_class.all.map { |s| s.diet_type.value }.uniq
        expect(diets).to contain_exactly(:carnivore, :piscivore, :insectivore, :herbivore, :frugivore, :omnivore)
      end

      describe '.find' do
        it "既知のキー 'lion' を渡すと対応する Species を返すこと" do
          expect(described_class.find('lion')).to eq(described_class.lion)
        end

        it "未知のキー 'dragon' を渡すと nil を返すこと" do
          expect(described_class.find('dragon')).to be_nil
        end
      end
    end
  end
end
