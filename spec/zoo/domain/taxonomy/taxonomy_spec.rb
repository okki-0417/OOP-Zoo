# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Taxonomy
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

        it '適温域への適合を判定できること' do
          expect(lion.habitable?(Shared::Temperature.celsius(30))).to be(true)
          expect(polar_bear.habitable?(Shared::Temperature.celsius(30))).to be(false)
        end

        it '体格と行動様式に応じた必要面積を返すこと(最小5m²)' do
          expect(lion.space_requirement_sqm).to eq(95)
          expect(SpeciesCatalog.hercules_beetle.space_requirement_sqm).to eq(5)
        end

        it '快適か(適温域の内側か)を判定できること' do
          expect(lion.comfortable?(Shared::Temperature.celsius(25))).to be(true)
          expect(lion.comfortable?(Shared::Temperature.celsius(12))).to be(false)
          expect(lion.comfortable?(Shared::Temperature.celsius(50))).to be(false)
        end

        it '気候域の重なりを判定できること(ライオンとコウテイペンギンは気候が両立しない)' do
          expect(lion.climate_overlaps?(zebra)).to be(true)
          expect(lion.climate_overlaps?(SpeciesCatalog.emperor_penguin)).to be(false)
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
end
