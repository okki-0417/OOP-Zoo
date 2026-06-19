# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '評判の動学' do
  reputation = Zoo::Domain::Reputation

  CROWD = Zoo::Domain::Reputation::EXPOSURE_REFERENCE

  describe '体験経路(来た人が評判を育てる)' do
    context '良い体験の日がにぎわうと' do
      it '評判がゆっくり上がること' do
        after = reputation.new(50).after_day(experience: 96, exposure: CROWD)
        expect(after.score).to be > 50
      end
    end

    context '悪い体験(福祉の崩れた展示)の日がにぎわうと' do
      it '評判が下がること' do
        after = reputation.new(80).after_day(experience: 56, exposure: CROWD)
        expect(after.score).to be < 80
      end
    end

    it '1日の評判の上げ幅は緩やか(ドリフト上限 DRIFT_CAP 以内)であること' do
      after = reputation.new(0).after_day(experience: 100, exposure: CROWD)
      expect(after.score).to be <= Zoo::Domain::Reputation::DRIFT_CAP
    end
  end

  describe '露出(口コミの量)' do
    it '来場が多い日ほど、同じ体験でも評判が大きく動くこと' do
      busy  = reputation.new(50).after_day(experience: 100, exposure: 200).value
      quiet = reputation.new(50).after_day(experience: 100, exposure: 5).value
      expect(busy - 50).to be > (quiet - 50)
    end

    it '来場ゼロの日は、体験経路では評判が動かないこと' do
      after = reputation.new(50).after_day(experience: 100, exposure: 0)
      expect(after.score).to eq(50)
    end
  end

  describe '自然減衰(築いた評判は維持しないと錆びる)' do
    it '来園も良い出来事もない日が続くと、築いた評判(中立超え)は徐々に下がること' do
      after = reputation.new(90).after_day(experience: 100, exposure: 0)
      expect(after.value).to be < 90
    end

    it '中立(平均的な評判)は、放置しても下がらないこと(錆びるのは築いた分だけ)' do
      after = reputation.new(50).after_day(experience: 100, exposure: 0)
      expect(after.value).to eq(50)
    end
  end

  describe 'ニュースの重み(評判をどれだけ下げるか)' do
    event = Zoo::Domain::ReputationEvent

    context '死因(帰責性)で重みが変わる' do
      it '予防可能な死(餓死)は、老衰死より評判を大きく下げること' do
        starved = reputation.new(80).after_day(experience: 100, exposure: 0,
                                               events: [event::Death.new(cause: :starvation, charisma: 50)])
        old_age = reputation.new(80).after_day(experience: 100, exposure: 0,
                                               events: [event::Death.new(cause: :old_age, charisma: 50)])
        expect(starved.score).to be < old_age.score
      end
    end

    context '対象の格(カリスマ性)で重みが変わる' do
      it '同じ死因でも、カリスマ性の高い個体ほど評判を大きく下げること' do
        star  = reputation.new(80).after_day(experience: 100, exposure: 0,
                                             events: [event::Death.new(cause: :old_age, charisma: 90)])
        minor = reputation.new(80).after_day(experience: 100, exposure: 0,
                                             events: [event::Death.new(cause: :old_age, charisma: 10)])
        expect(star.score).to be < minor.score
      end
    end
  end

  describe '非対称性(信用は築くより失うが速い)' do
    it '同じ大きさの体験ギャップでも、下げ幅が上げ幅より大きいこと' do
      up   = reputation.new(50).after_day(experience: 100, exposure: CROWD).score - 50
      down = 50 - reputation.new(50).after_day(experience: 0, exposure: CROWD).score
      expect(down).to be > up
    end
  end

  describe '清潔・過密は評判の直接の入力ではない' do
    it '清潔度や過密そのものは評判式の引数ではなく、福祉→コンディション→体験 経由でのみ効くこと'
  end
end
