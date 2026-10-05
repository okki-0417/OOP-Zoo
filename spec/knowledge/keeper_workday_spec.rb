# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '飼育員の勤務と日課' do
  catalog = Zoo::Domain::SpeciesCatalog
  foods   = Zoo::Domain::FoodCatalog
  taxa    = Zoo::Domain::TaxonClass
  female  = Zoo::Domain::Animal::Sex.female

  def pen(name = 'ライオンの丘', capacity: 4)
    Zoo::Domain::Enclosure.new(name:, temperature: Zoo::Domain::Shared::Temperature.celsius(24), capacity:)
  end

  def rounding(keeper, enclosure, occupants, assignees: [keeper])
    Zoo::Domain::Rounding.new(
      keeper:, occupancy: build_occupancy(enclosure, occupants),
      assignment: Zoo::Domain::Assignment.new(enclosure, assignees), foods: Zoo::Domain::FoodCatalog.all
    )
  end

  describe '勤務時間' do
    it '飼育員が1日に働けるのは8時間(480分)であること' do
      expect(build_keeper.remaining_minutes).to eq(480)
    end

    it '給餌1回で10分、清掃で60分、遊具などの補充(エンリッチメント)で30分の勤務時間を使うこと' do
      keeper = build_keeper
      Zoo::Domain::Feeding.new(keeper:, animal: build_adult(catalog.lion), foods: [foods.horse_meat]).serve
      Zoo::Domain::Cleaning.new(keeper:, enclosure: pen).perform
      Zoo::Domain::Enriching.new(keeper:, enclosure: pen).perform

      expect(keeper.remaining_minutes).to eq(480 - 10 - 60 - 30)
    end

    context '勤務時間を使い切った飼育員は' do
      it 'その日はもう給餌できないこと' do
        keeper = build_keeper
        keeper.clock_in(480)

        expect { Zoo::Domain::Feeding.new(keeper:, animal: build_adult(catalog.lion), foods: [foods.horse_meat]).serve }
          .to raise_error(Zoo::Domain::Errors::FeedingNotAllowed, /勤務時間/)
      end

      it 'その日はもう清掃できないこと' do
        keeper = build_keeper
        keeper.clock_in(450)

        expect { Zoo::Domain::Cleaning.new(keeper:, enclosure: pen).perform }
          .to raise_error(Zoo::Domain::Errors::WorkNotAllowed, /勤務時間/)
      end
    end

    context '1日が終わると' do
      it '勤務時間がリセットされ、翌日はまた8時間働けること' do
        keeper = build_keeper
        keeper.clock_in(300)
        keeper.end_shift

        expect(keeper.remaining_minutes).to eq(480)
      end
    end
  end

  describe '給餌計画(その日に与える餌の組み合わせ)' do
    def ration_of(animal)
      Zoo::Domain::Ration.new(animal:, foods: Zoo::Domain::FoodCatalog.all)
    end

    it '肉食のライオンには肉だけを与えること' do
      expect(ration_of(build_adult(catalog.lion)).foods.map(&:category).uniq).to eq([:meat])
    end

    it '雑食のニホンザルには、栄養が偏らないよう2種類以上の餌の分類を組み合わせること' do
      expect(ration_of(build_adult(catalog.japanese_macaque)).foods.map(&:category).uniq.size).to be >= 2
    end

    it '計画どおりに与えると、その日の栄養の多様性が満たされること' do
      monkey = build_adult(catalog.japanese_macaque)
      expect(Zoo::Domain::Feeding.new(animal: monkey, foods: ration_of(monkey).foods).nutritionally_adequate?)
        .to be(true)
    end

    it 'お腹を空かせているほど量を増やし、空腹を満たせるだけの餌を出すこと' do
      lion = build_adult(catalog.lion).get_hungrier(90)
      ration = ration_of(lion)

      expect(Zoo::Domain::Feeding.new(animal: lion, foods: ration.foods).satiety).to be >= 90
      expect(ration.foods.size).to be > ration_of(build_adult(catalog.lion)).foods.size
    end
  end

  describe '担当エリアの見回り' do
    let(:keeper) { build_keeper(taxa.mammal) }

    it '担当エリアの、その日まだ食べていない動物に給餌計画どおりの餌を与えること' do
      leo = build_adult(catalog.lion, name: 'レオ').get_hungrier(60)
      nala = build_adult(catalog.lion, name: 'ナラ', sex: female).get_hungrier(60)

      report = rounding(keeper, pen, [leo, nala]).perform

      expect(report.fed.map(&:name)).to contain_exactly('レオ', 'ナラ')
      expect([leo, nala].map(&:hunger_level)).to all(eq(0))
      expect(leo.meals.categories).to eq([:meat])
    end

    it 'その日すでに食べた動物には重ねて与えないこと' do
      leo = build_adult(catalog.lion, name: 'レオ')
      Zoo::Domain::Feeding.new(keeper:, animal: leo, foods: [foods.horse_meat]).serve

      expect(rounding(keeper, pen, [leo]).perform.fed).to be_empty
    end

    it '汚れてきた(清潔度70以下)エリアは清掃すること' do
      enclosure = pen.tap { |e| e.soil(30) }
      report = rounding(keeper, enclosure, [build_adult(catalog.lion)]).perform

      expect(report).to be_cleaned
      expect(enclosure.cleanliness_level).to eq(100)
    end

    it '刺激が乏しくなってきた(刺激度50以下)エリアには遊具などを補充すること' do
      enclosure = pen.tap { |e| e.deplete_enrichment(50) }
      report = rounding(keeper, enclosure, [build_adult(catalog.lion)]).perform

      expect(report).to be_enriched
      expect(enclosure).not_to be_barren
    end

    it '担当していないエリアは見回れないこと' do
      other = build_keeper(taxa.mammal)
      expect { rounding(keeper, pen, [build_adult(catalog.lion)], assignees: [other]).perform }
        .to raise_error(Zoo::Domain::Errors::WorkNotAllowed, /担当/)
    end

    it '専門外の動物には給餌せず、見送った理由を記録すること' do
      bird_keeper = build_keeper(taxa.bird)
      leo = build_adult(catalog.lion, name: 'レオ')

      report = rounding(bird_keeper, pen, [leo]).perform

      expect(report.fed).to be_empty
      expect(report.skipped).to include(%w[レオ 専門外のため給餌できません])
    end

    context '勤務時間が足りないと' do
      it '給餌を最優先し、清掃と補充は見送ること' do
        enclosure = pen.tap { |e| e.soil(50) }.tap { |e| e.deplete_enrichment(60) }
        leo = build_adult(catalog.lion, name: 'レオ')
        keeper.clock_in(460)

        report = rounding(keeper, enclosure, [leo]).perform

        expect(report.fed.map(&:name)).to eq(['レオ'])
        expect(report).not_to be_cleaned
        expect(report.skipped).to include(%w[ライオンの丘 勤務時間が足りず清掃できません],
                                          %w[ライオンの丘 勤務時間が足りず遊具を補充できません])
      end

      it '給餌しきれなかった動物を見送ったと記録すること' do
        leo = build_adult(catalog.lion, name: 'レオ')
        nala = build_adult(catalog.lion, name: 'ナラ', sex: female)
        keeper.clock_in(470)

        report = rounding(keeper, pen, [leo, nala]).perform

        expect(report.fed.size).to eq(1)
        expect(report.skipped.map(&:last)).to include('勤務時間が足りず給餌できません')
      end
    end
  end
end
