# frozen_string_literal: true

require 'spec_helper'

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

  CROWD = Zoo::Domain::Operations::ReputationPolicy::EXPOSURE_REFERENCE

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
      busy  = policy.after_day(reputation.new(50), experience: 100, exposure: 200).value
      quiet = policy.after_day(reputation.new(50), experience: 100, exposure: 5).value
      expect(busy - 50).to be > (quiet - 50)
    end

    it '来場ゼロの日は、体験経路では評判が動かないこと' do
      after = policy.after_day(reputation.new(50), experience: 100, exposure: 0)
      expect(after.score).to eq(50)
    end
  end

  describe '自然減衰(築いた評判は維持しないと錆びる)' do
    it '来園も良い出来事もない日が続くと、築いた評判(中立超え)は徐々に下がること' do
      after = policy.after_day(reputation.new(90), experience: 100, exposure: 0)
      expect(after.value).to be < 90
    end

    it '中立(平均的な評判)は、放置しても下がらないこと(錆びるのは築いた分だけ)' do
      after = policy.after_day(reputation.new(50), experience: 100, exposure: 0)
      expect(after.value).to eq(50)
    end
  end

  describe 'ニュースの重み(評判をどれだけ下げるか)' do
    event = Zoo::Domain::Operations::ReputationEvent

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

    it '混雑しすぎると体験が下がること'

    it '動物が見えない(見せ場が低い)と体験が下がること'
  end

  describe '清潔・過密は評判の直接の入力ではない' do
    it '清潔度や過密そのものは評判式の引数ではなく、福祉→コンディション→体験 経由でのみ効くこと'
  end
end
