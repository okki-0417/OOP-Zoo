# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DietType do
  describe '#accepts?' do
    context '肉食(.carnivore)のとき' do
      subject(:diet) { described_class.carnivore }

      it ':meat に true、:plant に false を返すこと' do
        expect(diet.accepts?(:meat)).to be(true)
        expect(diet.accepts?(:plant)).to be(false)
      end
    end

    context '雑食(.omnivore)のとき' do
      subject(:diet) { described_class.omnivore }

      it ':meat にも :plant にも true を返すこと' do
        expect(diet.accepts?(:meat)).to be(true)
        expect(diet.accepts?(:plant)).to be(true)
      end
    end
  end

  describe '#predatory?' do
    it '肉食(.carnivore)・魚食(.piscivore)は true を返すこと' do
      expect(described_class.carnivore).to be_predatory
      expect(described_class.piscivore).to be_predatory
    end

    it '草食(.herbivore)・昆虫食(.insectivore)は false を返すこと' do
      expect(described_class.herbivore).not_to be_predatory
      expect(described_class.insectivore).not_to be_predatory
    end
  end
end

RSpec.describe ConservationStatus do
  describe '#<=>' do
    it '深刻度で比較し、CR > LC・EN > VU となること' do
      expect(described_class.critically_endangered).to be > described_class.least_concern
      expect(described_class.endangered).to be > described_class.vulnerable
    end
  end

  describe '#threatened?' do
    it 'EN は true、LC は false を返すこと' do
      expect(described_class.endangered).to be_threatened
      expect(described_class.least_concern).not_to be_threatened
    end
  end

  describe '#extinct?' do
    it 'EX は true を返すこと' do
      expect(described_class.extinct).to be_extinct
    end
  end
end

RSpec.describe TaxonClass do
  describe '#warm_blooded? / #viviparous?' do
    it '哺乳類(.mammal)は true を返すこと' do
      expect(described_class.mammal).to be_warm_blooded
      expect(described_class.mammal).to be_viviparous
    end
  end

  describe '#oviparous?' do
    it '鳥類(.bird)・爬虫類(.reptile)は true を返すこと' do
      expect(described_class.bird).to be_oviparous
      expect(described_class.reptile).to be_oviparous
    end
  end

  describe '#cold_blooded?' do
    it '魚類(.fish)は true を返すこと' do
      expect(described_class.fish).to be_cold_blooded
    end
  end
end

RSpec.describe Species do
  let(:lion) { SpeciesCatalog.lion }
  let(:zebra) { SpeciesCatalog.grevys_zebra }

  describe '#==' do
    it '同じ学名のライオンどうしは等しく、ライオンとグレビーシマウマは等しくないこと' do
      expect(SpeciesCatalog.lion).to eq(SpeciesCatalog.lion)
      expect(lion).not_to eq(zebra)
    end
  end

  describe '#predatory? / #group_living? / #solitary?' do
    it 'ライオンは捕食性で群れ性、グレビーシマウマは非捕食性、ホッキョクグマは単独性であること' do
      expect(lion).to be_predatory
      expect(lion).to be_group_living
      expect(zebra).not_to be_predatory
      expect(SpeciesCatalog.polar_bear).to be_solitary
    end
  end

  describe '#space_requirement_sqm' do
    it 'ライオンは 95、ヘラクレスオオカブトは下限の 5 を返すこと' do
      expect(lion.space_requirement_sqm).to eq(95)
      expect(SpeciesCatalog.hercules_beetle.space_requirement_sqm).to eq(5)
    end
  end

  describe '#required_food_variety' do
    context '受け入れカテゴリが1つの肉食(ライオン)のとき' do
      it '1 を返すこと' do
        expect(lion.required_food_variety).to eq(1)
      end
    end

    context '受け入れカテゴリが多い雑食(ニホンザル)のとき' do
      it '上限の 2 を返すこと' do
        expect(SpeciesCatalog.japanese_macaque.required_food_variety).to eq(2)
      end
    end
  end

  describe '#accepts?' do
    it 'ライオンは :meat に true、:plant に false を返すこと' do
      expect(lion.accepts?(:meat)).to be(true)
      expect(lion.accepts?(:plant)).to be(false)
    end
  end

  describe '#daily_hunger' do
    it 'アフリカゾウでも HUNGER_MIN..HUNGER_MAX に収まること' do
      expect(SpeciesCatalog.african_elephant.daily_hunger)
        .to be_between(described_class::HUNGER_MIN, described_class::HUNGER_MAX)
    end
  end

  describe '#metabolic_factor' do
    it '小型のニホンザルは大型のアフリカゾウより大きいこと' do
      expect(SpeciesCatalog.japanese_macaque.metabolic_factor)
        .to be > SpeciesCatalog.african_elephant.metabolic_factor
    end
  end

  describe '#daily_food_cost' do
    subject(:cost) { SpeciesCatalog.hercules_beetle.daily_food_cost }

    it 'ヘラクレスオオカブトでも FOOD_COST_MIN_YEN 以上の Money を返すこと' do
      expect(cost).to be_a(Money)
      expect(cost.yen).to be >= described_class::FOOD_COST_MIN_YEN
    end
  end
end

RSpec.describe SpeciesCatalog do
  describe '.all' do
    subject(:species) { described_class.all }

    it '15種の Species を返すこと' do
      expect(species.size).to eq(15)
      expect(species).to all(be_a(Species))
    end

    it '6つの綱すべてを含むこと' do
      expect(species.map { |s| s.taxon_class.value }.uniq)
        .to contain_exactly(:mammal, :bird, :reptile, :amphibian, :fish, :invertebrate)
    end

    it '6つの食性すべてを含むこと' do
      expect(species.map(&:diet_label).uniq).to contain_exactly('肉食', '魚食', '昆虫食', '草食', '果実食', '雑食')
    end
  end

  describe '.find' do
    subject(:found) { described_class.find(key) }

    context "既知のキー 'lion' のとき" do
      let(:key) { 'lion' }

      it 'ライオンの Species を返すこと' do
        expect(found).to eq(described_class.lion)
      end
    end

    context "未知のキー 'dragon' のとき" do
      let(:key) { 'dragon' }

      it 'nil を返すこと' do
        expect(found).to be_nil
      end
    end
  end
end
