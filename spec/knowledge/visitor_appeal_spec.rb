# frozen_string_literal: true

require 'spec_helper'

# 集客の魅力の知識。来園者を惹きつけるのは保全ランク(希少性)そのものではなく、
# 種のカリスマ性(フラッグシップ種)・展示の多様性・話題(幼獣の誕生)である。
# 集客 = f(魅力, 評判, 料金) であり、福祉そのものは集客の直接の引数ではない。
# 福祉は「来た人の体験 → 評判」を経由して(遅延して)集客に効く(reputation_spec を参照)。
RSpec.describe '集客の魅力' do
  catalog    = Zoo::Domain::Taxonomy::SpeciesCatalog
  attraction = Zoo::Domain::Operations::VisitorAttraction
  reputation = Zoo::Domain::Operations::Reputation
  money      = Zoo::Domain::Shared::Money

  rep = Zoo::Domain::Operations::Reputation.new(100)
  fee = Zoo::Domain::Shared::Money.yen(2_000)

  def herd(species, count: 1, stress: 0)
    Array.new(count) do
      animal = build_adult(species)
      animal.add_stress(stress) if stress.positive?
      animal
    end
  end

  describe '魅力の源泉' do
    it 'カリスマ性の高い種ほど強く集客すること(ライオン > ニシキゴイ)' do
      expect(attraction.expected_visitors(herd(catalog.lion), rep, fee))
        .to be > attraction.expected_visitors(herd(catalog.koi), rep, fee)
    end

    it '希少度が同じでもカリスマ性が低ければ集客に寄与しにくいこと(ともにVUのライオン > ニシキヘビ)' do
      expect(attraction.expected_visitors(herd(catalog.lion), rep, fee))
        .to be > attraction.expected_visitors(herd(catalog.burmese_python), rep, fee)
    end

    it '展示種の多様性も集客に寄与すること' do
      diverse = [build_adult(catalog.lion), build_adult(catalog.grevys_zebra)]
      single = [build_adult(catalog.lion)]
      expect(attraction.expected_visitors(diverse, rep, fee))
        .to be > attraction.expected_visitors(single, rep, fee)
    end
  end

  describe '展示の質(福祉)は集客の直接の引数ではない' do
    it '同じ展示なら、福祉(ストレス)の良し悪しで同日の集客は変わらないこと' do
      content = herd(catalog.lion, count: 4)
      stressed = herd(catalog.lion, count: 4, stress: 70)
      expect(attraction.expected_visitors(stressed, rep, fee))
        .to eq(attraction.expected_visitors(content, rep, fee))
    end
  end

  describe '話題性' do
    it '幼獣誕生などの話題は一時的に集客を押し上げること' do
      animals = herd(catalog.lion)
      with_buzz = attraction.expected_visitors(animals, rep, fee, buzz: 100)
      without_buzz = attraction.expected_visitors(animals, rep, fee, buzz: 0)
      expect(with_buzz).to be > without_buzz
    end

    it '話題は時間とともに薄れること' do
      zoo = Zoo::Domain::Zoo.new(name: '園', admission_fee: money.yen(2_000))
      zoo.generate_buzz(100)
      expect { zoo.advance_day }.to change(zoo, :buzz).by(-Zoo::Domain::Zoo::BUZZ_DECAY_PER_DAY)
    end
  end
end
