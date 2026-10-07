# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '飼育員の勤務と日課' do
  female = Animal::Sex.female

  def pen(name = 'ライオンの丘', capacity: 4)
    Enclosure.new(name:, temperature: Temperature.celsius(24), capacity:)
  end

  def rounding(keeper, enclosure, occupants, assignees: [keeper])
    assignees.each { |assignee| assignee.enclosures << enclosure }
    Rounding.new(
      keeper:, occupancy: build_occupancy(enclosure, occupants), foods: FoodCatalog.all
    )
  end

  describe '勤務時間' do
    it '飼育員が1日に働けるのは8時間(480分)であること' do
      expect(build_keeper.remaining_minutes).to eq(480)
    end

    it '給餌1回で10分、清掃で60分、遊具などの補充(エンリッチメント)で30分の勤務時間を使うこと' do
      keeper = build_keeper
      Feeding.new(keeper:, animal: build_adult(SpeciesCatalog.lion), foods: [FoodCatalog.horse_meat]).serve
      Cleaning.new(keeper:, enclosure: pen).perform
      Enriching.new(keeper:, enclosure: pen).perform

      expect(keeper.remaining_minutes).to eq(480 - 10 - 60 - 30)
    end

    context '勤務時間を使い切った飼育員は' do
      it 'その日はもう給餌できないこと' do
        keeper = build_keeper
        keeper.clock_in(480)

        expect { Feeding.new(keeper:, animal: build_adult(SpeciesCatalog.lion), foods: [FoodCatalog.horse_meat]).serve }
          .to raise_error(Errors::FeedingNotAllowed, /勤務時間/)
      end

      it 'その日はもう清掃できないこと' do
        keeper = build_keeper
        keeper.clock_in(450)

        expect { Cleaning.new(keeper:, enclosure: pen).perform }
          .to raise_error(Errors::WorkNotAllowed, /勤務時間/)
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

  describe '日課の手入れが要る状態' do
    it '清潔度70以下に汚れてきたエリアは、不潔(30以下)になる前でも清掃が要ること' do
      expect(pen.tap { |e| e.soil(30) }).to be_soiled
      expect(pen.tap { |e| e.soil(30) }).not_to be_filthy
      expect(pen.tap { |e| e.soil(29) }).not_to be_soiled
    end

    it '刺激度50以下に減ってきたエリアは、退屈(30以下)になる前でも遊具などの補充が要ること' do
      expect(pen.tap { |e| e.deplete_enrichment(50) }).to be_dull
      expect(pen.tap { |e| e.deplete_enrichment(50) }).not_to be_barren
      expect(pen.tap { |e| e.deplete_enrichment(49) }).not_to be_dull
    end

    it 'その日に一度でも餌を食べた動物は給餌済みで、1日が終わるとまた未給餌に戻ること' do
      lion = build_adult(SpeciesCatalog.lion)
      expect(lion).not_to be_fed_today

      Feeding.new(keeper: build_keeper, animal: lion, foods: [FoodCatalog.horse_meat]).serve
      expect(lion).to be_fed_today

      lion.settle_nutrition
      expect(lion).not_to be_fed_today
    end
  end

  describe '給餌計画(その日に与える餌の組み合わせ)' do
    def ration_of(animal)
      Ration.new(animal:, foods: FoodCatalog.all)
    end

    it '肉食のライオンには肉だけを与えること' do
      expect(ration_of(build_adult(SpeciesCatalog.lion)).foods.map(&:category).uniq).to eq([:meat])
    end

    it '雑食のニホンザルには、栄養が偏らないよう2種類以上の餌の分類を組み合わせること' do
      expect(ration_of(build_adult(SpeciesCatalog.japanese_macaque)).foods.map(&:category).uniq.size).to be >= 2
    end

    it '計画どおりに与えると、その日の栄養の多様性が満たされること' do
      monkey = build_adult(SpeciesCatalog.japanese_macaque)
      expect(Feeding.new(animal: monkey, foods: ration_of(monkey).foods).nutritionally_adequate?)
        .to be(true)
    end

    it 'お腹を空かせているほど量を増やし、空腹を満たせるだけの餌を出すこと' do
      lion = build_adult(SpeciesCatalog.lion).get_hungrier(90)
      ration = ration_of(lion)

      expect(Feeding.new(animal: lion, foods: ration.foods).satiety).to be >= 90
      expect(ration.foods.size).to be > ration_of(build_adult(SpeciesCatalog.lion)).foods.size
    end
  end

  describe '担当エリアの見回り' do
    let(:keeper) { build_keeper(TaxonClass.mammal) }

    it '担当エリアの、その日まだ食べていない動物に給餌計画どおりの餌を与えること' do
      leo = build_adult(SpeciesCatalog.lion, name: 'レオ').get_hungrier(60)
      nala = build_adult(SpeciesCatalog.lion, name: 'ナラ', sex: female).get_hungrier(60)

      report = rounding(keeper, pen, [leo, nala]).perform

      expect(report.fed.map(&:name)).to contain_exactly('レオ', 'ナラ')
      expect([leo, nala].map(&:hunger_level)).to all(eq(0))
      expect(leo.meals.categories).to eq([:meat])
    end

    it 'その日すでに食べた動物には重ねて与えないこと' do
      leo = build_adult(SpeciesCatalog.lion, name: 'レオ')
      Feeding.new(keeper:, animal: leo, foods: [FoodCatalog.horse_meat]).serve

      expect(rounding(keeper, pen, [leo]).perform.fed).to be_empty
    end

    it '汚れてきた(清潔度70以下)エリアは清掃すること' do
      enclosure = pen.tap { |e| e.soil(30) }
      report = rounding(keeper, enclosure, [build_adult(SpeciesCatalog.lion)]).perform

      expect(report).to be_cleaned
      expect(enclosure.cleanliness_level).to eq(100)
    end

    it '刺激が乏しくなってきた(刺激度50以下)エリアには遊具などを補充すること' do
      enclosure = pen.tap { |e| e.deplete_enrichment(50) }
      report = rounding(keeper, enclosure, [build_adult(SpeciesCatalog.lion)]).perform

      expect(report).to be_enriched
      expect(enclosure).not_to be_barren
    end

    it '担当していないエリアは見回れないこと' do
      other = build_keeper(TaxonClass.mammal)
      expect { rounding(keeper, pen, [build_adult(SpeciesCatalog.lion)], assignees: [other]).perform }
        .to raise_error(Errors::WorkNotAllowed, /担当/)
    end

    it '専門外の動物には給餌せず、見送った理由を記録すること' do
      bird_keeper = build_keeper(TaxonClass.bird)
      leo = build_adult(SpeciesCatalog.lion, name: 'レオ')

      report = rounding(bird_keeper, pen, [leo]).perform

      expect(report.fed).to be_empty
      expect(report.skipped).to include(%w[レオ 専門外のため給餌できません])
    end

    context '勤務時間が足りないと' do
      it '給餌を最優先し、清掃と補充は見送ること' do
        enclosure = pen.tap { |e| e.soil(50) }.tap { |e| e.deplete_enrichment(60) }
        leo = build_adult(SpeciesCatalog.lion, name: 'レオ')
        keeper.clock_in(460)

        report = rounding(keeper, enclosure, [leo]).perform

        expect(report.fed.map(&:name)).to eq(['レオ'])
        expect(report).not_to be_cleaned
        expect(report.skipped).to include(%w[ライオンの丘 勤務時間が足りず清掃できません],
                                          %w[ライオンの丘 勤務時間が足りず遊具を補充できません])
      end

      it '給餌しきれなかった動物を見送ったと記録すること' do
        leo = build_adult(SpeciesCatalog.lion, name: 'レオ')
        nala = build_adult(SpeciesCatalog.lion, name: 'ナラ', sex: female)
        keeper.clock_in(470)

        report = rounding(keeper, pen, [leo, nala]).perform

        expect(report.fed.size).to eq(1)
        expect(report.skipped.map(&:last)).to include('勤務時間が足りず給餌できません')
      end
    end
  end
end
