# frozen_string_literal: true

require 'spec_helper'

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

RSpec.describe Feeding do
  let(:keeper) { build(:keeper) }
  let(:bird_keeper) { build(:keeper, specialties: [TaxonClass.bird]) }
  let(:lion) { build(:animal) }
  let(:macaque) { build(:animal, species: SpeciesCatalog.japanese_macaque) }
  let(:elephant) { build(:animal, species: SpeciesCatalog.african_elephant) }

  def feeding(animal, foods, by: keeper)
    described_class.new(keeper: by, animal: animal, foods: foods)
  end

  describe '#serve' do
    before { lion.get_hungrier(50) }

    it '食性に合う餌で空腹が満たされること' do
      expect { feeding(lion, [FoodCatalog.horse_meat]).serve }
        .to change { lion.hunger_level }.by(-35)
    end

    it '食性に合わない餌は FeedingNotAllowed であること' do
      expect { feeding(lion, [FoodCatalog.hay]).serve }
        .to raise_error(Errors::FeedingNotAllowed, /与えられません/)
    end

    it '専門外の飼育員は FeedingNotAllowed であること' do
      expect { feeding(lion, [FoodCatalog.horse_meat], by: bird_keeper).serve }
        .to raise_error(Errors::FeedingNotAllowed, /担当できません/)
    end

    it '死亡個体は FeedingNotAllowed であること' do
      lion.die
      expect { feeding(lion, [FoodCatalog.horse_meat]).serve }
        .to raise_error(Errors::FeedingNotAllowed, /死亡/)
    end

    it '給餌1回で飼育員の勤務時間を WORK_MINUTES(10分)使うこと' do
      expect { feeding(lion, [FoodCatalog.horse_meat]).serve }.to change { keeper.worked_minutes }.by(10)
    end

    it '飼育員の残り勤務時間が9分なら FeedingNotAllowed になり、空腹は変わらないこと' do
      keeper.clock_in(471)
      expect { feeding(lion, [FoodCatalog.horse_meat]).serve }
        .to raise_error(Errors::FeedingNotAllowed, /勤務時間が足りません\(残り9分\)/)
      expect(lion.hunger_level).to eq(50)
    end

    it '複数の違反をまとめて報告すること' do
      lion.die
      expect { feeding(lion, [FoodCatalog.hay], by: bird_keeper).serve }
        .to raise_error(Errors::FeedingNotAllowed, /担当できません.*死亡.*与えられません/)
    end
  end

  describe '#satiety' do
    it '複数の餌の満腹度を合算すること' do
      combined = feeding(lion, [FoodCatalog.horse_meat, FoodCatalog.chicken]).satiety
      separate = feeding(lion, [FoodCatalog.horse_meat]).satiety + feeding(lion, [FoodCatalog.chicken]).satiety
      expect(combined).to eq(separate)
    end

    it '満腹度は最低1を返すこと' do
      expect(feeding(elephant, [FoodCatalog.hay]).satiety).to be >= 1
    end
  end

  describe '#nutritionally_adequate?' do
    it '必要カテゴリ数を満たせば true であること' do
      expect(feeding(lion, [FoodCatalog.horse_meat]).nutritionally_adequate?).to be(true)
    end

    it '食性に合わない餌はカテゴリに数えないこと' do
      expect(feeding(elephant, [FoodCatalog.hay, FoodCatalog.horse_meat]).nutritionally_adequate?).to be(false)
    end
  end

  describe '#serve の食事記録' do
    it '果実のバナナを与えると animal.meals.categories に :fruit が加わること' do
      feeding(macaque, [FoodCatalog.banana]).serve
      expect(macaque.meals.categories).to eq([:fruit])
    end

    it '同じ日に2回に分けてバナナとコオロギを与えると meals.categories が [:fruit, :insect] になること' do
      feeding(macaque, [FoodCatalog.banana]).serve
      feeding(macaque, [FoodCatalog.cricket]).serve
      expect(macaque.meals.categories).to eq(%i[fruit insect])
    end
  end
end
