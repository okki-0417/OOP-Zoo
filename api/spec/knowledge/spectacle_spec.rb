# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '集客の見応え' do
  def rep
    Zoo::Reputation.new(100).factor
  end

  def fee
    Money.yen(2_000)
  end

  def herd(species, count: 1, stress: 0)
    Array.new(count) do
      animal = build(:animal, species:)
      animal.add_stress(stress) if stress.positive?
      animal
    end
  end

  def visitors(on_exhibit, buzz: 0)
    zoo = double('zoo', reputation_factor: rep, admission_fee: fee, buzz: buzz)
    VisitorAttraction.new(on_exhibit: on_exhibit, zoo: zoo).expected_visitors
  end

  def spectacle(on_exhibit)
    Spectacle.new(on_exhibit: on_exhibit).value
  end

  describe '見応えの源泉' do
    it 'カリスマ性の高い種ほど強く集客すること(ライオン > ニシキゴイ)' do
      expect(visitors(herd(SpeciesCatalog.lion))).to be > visitors(herd(SpeciesCatalog.koi))
    end

    it '希少度が同じでもカリスマ性が低ければ集客に寄与しにくいこと(ともにVUのライオン > ニシキヘビ)' do
      expect(visitors(herd(SpeciesCatalog.lion))).to be > visitors(herd(SpeciesCatalog.burmese_python))
    end

    it 'カリスマある種を増やせば集客は増えること(多様化はカリスマ合計に内包され、種数そのものは加点しない)' do
      diverse = [build(:animal), build(:animal, species: SpeciesCatalog.grevys_zebra)]
      single = [build(:animal)]
      expect(visitors(diverse)).to be > visitors(single)
    end

    it '見応えは展示を増やすほど高まるが、増分は逓減すること(1日の鑑賞容量は有限)' do
      modest = [build(:animal, species: SpeciesCatalog.koi)]
      rich = [SpeciesCatalog.lion, SpeciesCatalog.african_elephant, SpeciesCatalog.polar_bear, SpeciesCatalog.red_panda].map do |s|
        build(:animal, species: s)
      end
      gain_when_modest = spectacle(modest + [build(:animal, species: SpeciesCatalog.grevys_zebra)]) - spectacle(modest)
      gain_when_rich = spectacle(rich + [build(:animal, species: SpeciesCatalog.grevys_zebra)]) - spectacle(rich)
      expect(gain_when_modest).to be > gain_when_rich
    end
  end

  describe '展示の質(福祉)は集客の直接の引数ではない' do
    it '同じ展示なら、福祉(ストレス)の良し悪しで同日の集客は変わらないこと' do
      content = herd(SpeciesCatalog.lion, count: 4)
      stressed = herd(SpeciesCatalog.lion, count: 4, stress: 70)
      expect(visitors(stressed)).to eq(visitors(content))
    end
  end

  describe '話題性' do
    it '幼獣誕生などの話題は一時的に集客を押し上げること' do
      animals = herd(SpeciesCatalog.lion)
      expect(visitors(animals, buzz: 100)).to be > visitors(animals, buzz: 0)
    end

    it '話題は時間とともに薄れること' do
      zoo = build(:zoo, name: '園', admission_fee: Money.yen(2_000))
      zoo.generate_buzz(100)
      expect { zoo.advance_day }.to change(zoo, :buzz).by(-Zoo::BUZZ_DECAY_PER_DAY)
    end
  end
end
