# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Food do
  describe '.new' do
    subject(:food) { described_class.new(name_ja: '餌', category:, satiety:) }

    let(:category) { :meat }
    let(:satiety) { 10 }

    context '未知のカテゴリ :unknown のとき' do
      let(:category) { :unknown }

      it 'ArgumentError が発生すること' do
        expect { food }.to raise_error(ArgumentError)
      end
    end

    context '満腹度が 0 のとき' do
      let(:satiety) { 0 }

      it 'ArgumentError が発生すること' do
        expect { food }.to raise_error(ArgumentError)
      end
    end
  end
end

RSpec.describe FoodCatalog do
  describe '.all' do
    it '餌のカテゴリが :meat・:fish・:insect・:plant・:fruit・:seed をすべて含むこと' do
      expect(described_class.all.map(&:category).uniq).to contain_exactly(:meat, :fish, :insect, :plant, :fruit, :seed)
    end
  end

  describe '.find' do
    context "既知のキー 'hay' のとき" do
      it '干し草の Food を返すこと' do
        expect(described_class.find('hay')).to eq(described_class.hay)
      end
    end

    context "未知のキー 'pizza' のとき" do
      it 'nil を返すこと' do
        expect(described_class.find('pizza')).to be_nil
      end
    end
  end
end

RSpec.describe Feeding do
  subject(:feeding) { described_class.new(keeper:, animal:, foods:) }

  let(:keeper) { build(:keeper) }
  let(:animal) { build(:animal) }
  let(:foods) { [FoodCatalog.horse_meat] }
  let(:bird_keeper) { build(:keeper, specialties: [TaxonClass.bird]) }

  describe '#serve' do
    before { animal.get_hungrier(50) }

    context '違反がないとき' do
      it '空腹度50のライオンの空腹度を馬肉の満腹度35だけ下げること' do
        expect { feeding.serve }.to change(animal, :hunger_level).by(-35)
      end

      it '飼育員の勤務時間を WORK_MINUTES(10分)使うこと' do
        expect { feeding.serve }.to change(keeper, :worked_minutes).by(10)
      end
    end

    context '食性に合わない干し草のとき' do
      let(:foods) { [FoodCatalog.hay] }

      it 'FeedingNotAllowed(与えられません) を投げること' do
        expect { feeding.serve }.to raise_error(Errors::FeedingNotAllowed, /与えられません/)
      end
    end

    context '鳥類専門の飼育員のとき' do
      let(:keeper) { bird_keeper }

      it 'FeedingNotAllowed(担当できません) を投げること' do
        expect { feeding.serve }.to raise_error(Errors::FeedingNotAllowed, /担当できません/)
      end
    end

    context '動物が死亡しているとき' do
      let(:animal) { build(:animal).die }

      it 'FeedingNotAllowed(死亡) を投げること' do
        expect { feeding.serve }.to raise_error(Errors::FeedingNotAllowed, /死亡/)
      end
    end

    context '飼育員の残り勤務時間が9分のとき' do
      let(:keeper) { build(:keeper).clock_in(471) }

      it 'FeedingNotAllowed(残り9分) を投げ、空腹度は50のままであること' do
        expect { feeding.serve }.to raise_error(Errors::FeedingNotAllowed, /勤務時間が足りません\(残り9分\)/)
        expect(animal.hunger_level).to eq(50)
      end
    end

    context '鳥類専門の飼育員が死亡したライオンに干し草を与えるとき' do
      let(:keeper) { bird_keeper }
      let(:animal) { build(:animal).die }
      let(:foods) { [FoodCatalog.hay] }

      it '担当・死亡・食性の違反をまとめて1つの FeedingNotAllowed で投げること' do
        expect { feeding.serve }.to raise_error(Errors::FeedingNotAllowed, /担当できません.*死亡.*与えられません/)
      end
    end

    context 'ニホンザルにバナナを与えるとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.japanese_macaque) }
      let(:foods) { [FoodCatalog.banana] }

      it 'meals.categories が [:fruit] になること' do
        feeding.serve

        expect(animal.meals.categories).to eq([:fruit])
      end

      context '同じ日にコオロギも与えたとき' do
        before { described_class.new(keeper:, animal:, foods: [FoodCatalog.cricket]).serve }

        it 'meals.categories が [:fruit, :insect] になること' do
          feeding.serve

          expect(animal.meals.categories).to contain_exactly(:fruit, :insect)
        end
      end
    end
  end

  describe '#satiety' do
    context '馬肉と鶏肉を与えるとき' do
      let(:foods) { [FoodCatalog.horse_meat, FoodCatalog.chicken] }
      let(:separate) do
        [FoodCatalog.horse_meat, FoodCatalog.chicken].sum do |food|
          described_class.new(keeper:, animal:, foods: [food]).satiety
        end
      end

      it '馬肉だけ・鶏肉だけの満腹度の合計を返すこと' do
        expect(feeding.satiety).to eq(separate)
      end
    end

    context 'アフリカゾウに干し草を与えるとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.african_elephant) }
      let(:foods) { [FoodCatalog.hay] }

      it '1以上を返すこと' do
        expect(feeding.satiety).to be >= 1
      end
    end
  end

  describe '#nutritionally_adequate?' do
    context 'ライオンに馬肉を与えるとき' do
      it 'true を返すこと' do
        expect(feeding.nutritionally_adequate?).to be(true)
      end
    end

    context 'アフリカゾウに干し草と食性に合わない馬肉を与えるとき' do
      let(:animal) { build(:animal, species: SpeciesCatalog.african_elephant) }
      let(:foods) { [FoodCatalog.hay, FoodCatalog.horse_meat] }

      it '馬肉をカテゴリに数えず false を返すこと' do
        expect(feeding.nutritionally_adequate?).to be(false)
      end
    end
  end
end
