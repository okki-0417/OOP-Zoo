# frozen_string_literal: true

require 'spec_helper'

# 評判(ストック)の動学の知識。
#
# 評判は「公衆が抱く、その園の質への蓄積された信念」。1日では動かず、過去が残る。
# 評判は二つの経路でしか動かない:
#
#   体験経路   … 来た人が見て感じた質(=体験)へ、評判がゆっくり引き寄せられる。
#                口コミなので、来場が多い日ほど強く動き、誰も来なければ動かない(露出)。
#   ニュース経路 … 死亡・疫病など、来てない人にも届く顕著な出来事。露出によらず即時に動く。
#
# 用語（経済ドメイン共通）:
#   集客 = f(魅力, 評判, 料金)。評判は集客の母数・支払意思を押し上げる係数。
#   体験 = g(コンディション, 料金との釣り合い〔, 混雑・見せ場…後段〕)。来た人が感じた質。
#   コンディション … 来園者が知覚する飼育の質(見える福祉+健康)。清潔/過密/刺激/栄養はここ経由。
#   露出 … その日の来場規模。体験が口コミとして評判に伝わる強さ。
#
#   評判' = 評判 + 露出 × ドリフト(体験 − 評判) + イベント   (ドリフトは非対称: 築くは遅く失うは速い)
RSpec.describe '評判の動学' do
  reputation = Zoo::Domain::Operations::Reputation
  policy     = Zoo::Domain::Operations::ReputationPolicy
  condition  = Zoo::Domain::Husbandry::Condition
  experience = Zoo::Domain::Operations::VisitorExperience
  money      = Zoo::Domain::Shared::Money

  def healthy_exhibit
    Array.new(3) { build_adult(Zoo::Domain::Taxonomy::SpeciesCatalog.lion) }
  end

  def stressed_exhibit
    Array.new(3) { build_adult(Zoo::Domain::Taxonomy::SpeciesCatalog.lion).tap { |a| a.add_stress(70) } }
  end

  # にぎわう一日(露出が十分)を既定にして、評判の動きを観察する。
  CROWD = 100

  describe '体験経路(来た人が評判を育てる)' do
    context '良い体験(健康で落ち着いた展示)の日がにぎわうと' do
      it '評判がゆっくり上がること' do
        good = experience.score(condition: condition.score(healthy_exhibit), fee: money.yen(2_000))
        after = policy.after_day(reputation.new(50), experience: good, exposure: CROWD)
        expect(after.score).to be > 50
      end
    end

    context '悪い体験(福祉の崩れた展示)の日がにぎわうと' do
      it '評判が下がること' do
        poor = experience.score(condition: condition.score(stressed_exhibit), fee: money.yen(2_000))
        after = policy.after_day(reputation.new(80), experience: poor, exposure: CROWD)
        expect(after.score).to be < 80
      end
    end

    it '1日の評判の上げ幅は緩やか(ドリフト上限 DRIFT_CAP 以内)であること' do
      after = policy.after_day(reputation.new(0), experience: 100, exposure: CROWD)
      expect(after.score).to be <= Zoo::Domain::Operations::ReputationPolicy::DRIFT_CAP
    end
  end

  describe '露出(口コミの量)' do
    it '来場が多い日ほど、同じ体験でも評判が大きく動くこと' do
      busy  = policy.after_day(reputation.new(50), experience: 100, exposure: 200).score
      quiet = policy.after_day(reputation.new(50), experience: 100, exposure: 5).score
      expect(busy - 50).to be > (quiet - 50)
    end

    it '来場ゼロの日は、体験経路では評判が動かないこと' do
      after = policy.after_day(reputation.new(50), experience: 100, exposure: 0)
      expect(after.score).to eq(50)
    end
  end

  # 「何がニュースになるか/どのチャネルか」は spec/knowledge/news_spec.rb(ニュース性)が持つ。
  # ここでは、ニュース(ReputationEvent)が評判を「どれだけ」下げるか=重みの大小だけを縛る。
  # 各出来事は自分が持つデータ(死因・対象のカリスマ性)から効きの大きさを自分で決める。
  describe 'ニュースの重み(評判をどれだけ下げるか)' do
    event = Zoo::Domain::Operations::ReputationEvent

    # 露出ゼロで体験ドリフトを殺し、ニュースの重みだけを比べる。
    context '死因(帰責性)で重みが変わる' do
      it '予防可能な死(餓死)は、老衰死より評判を大きく下げること' do
        starved = policy.after_day(reputation.new(80), experience: 100, exposure: 0,
                                   events: [event::Death.new(cause: :starvation, charisma: 50)])
        old_age = policy.after_day(reputation.new(80), experience: 100, exposure: 0,
                                   events: [event::Death.new(cause: :old_age, charisma: 50)])
        expect(starved.score).to be < old_age.score
      end
    end

    context '対象の格(カリスマ性)で重みが変わる' do
      it '同じ死因でも、カリスマ性の高い個体ほど評判を大きく下げること' do
        star  = policy.after_day(reputation.new(80), experience: 100, exposure: 0,
                                 events: [event::Death.new(cause: :old_age, charisma: 90)])
        minor = policy.after_day(reputation.new(80), experience: 100, exposure: 0,
                                 events: [event::Death.new(cause: :old_age, charisma: 10)])
        expect(star.score).to be < minor.score
      end
    end
  end

  describe '非対称性(信用は築くより失うが速い)' do
    it '同じ大きさの体験ギャップでも、下げ幅が上げ幅より大きいこと' do
      up   = policy.after_day(reputation.new(50), experience: 100, exposure: CROWD).score - 50
      down = 50 - policy.after_day(reputation.new(50), experience: 0, exposure: CROWD).score
      expect(down).to be > up
    end
  end

  describe '体験はコンディションを「料金のレンズ」越しに見たもの' do
    it 'コンディションが良いほど体験が良いこと' do
      expect(experience.score(condition: 90, fee: money.yen(2_000)))
        .to be > experience.score(condition: 30, fee: money.yen(2_000))
    end

    it '同じコンディションでも料金が高いほど体験が下がること(期待とのギャップ)' do
      expect(experience.score(condition: 80, fee: money.yen(5_000)))
        .to be < experience.score(condition: 80, fee: money.yen(1_000))
    end

    # 来園者収容力(visitor capacity)の導入で対応。混雑は自分の成功で起きる自己抑制。
    it '混雑しすぎると体験が下がること'
    # 見せ場(可視性)の導入で対応。出てこない動物は魅力にも体験にも効かない。
    it '動物が見えない(見せ場が低い)と体験が下がること'
  end

  describe '清潔・過密は評判の直接の入力ではない' do
    it '清潔度や過密そのものは評判式の引数ではなく、福祉→コンディション→体験 経由でのみ効くこと'
  end
end
