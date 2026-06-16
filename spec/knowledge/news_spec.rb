# frozen_string_literal: true

require 'spec_helper'

# ニュース性(newsworthiness)の知識。
#
# 園で起きる出来事のうち「来ていない公衆にまで届く」ほど顕著なものだけがニュースになる。
# ニュースは2つのチャネルのどちらか(または両方)で園に効く:
#   信頼チャネル(評判) … 死・疫病・スキャンダル・保全実績。露出によらず評判(ストック)を動かす。
#   話題チャネル(魅力) … 誕生・新展示・季節イベント。buzzとして一時的に魅力(現在値)を上げる。
# 日常運営(採食・清掃・世話)は顕著でなく、ニュースにならない(来た人の体験経由でしか効かない)。
#
# 作用的定義: 「ニュースになる」= 露出ゼロ(来園なし)でも園の数値(評判 or 魅力)を動かすこと。
#
# 用語の2軸(集客の二大ドライバ。集客力 ≒ 魅力 × 評判):
#   魅力 … 見たさ・引き「何が見られるか」。在園構成から毎日計算し直す現在値(記憶なし)。
#   評判 … 信頼・評価「うまく運営されているか」。過去を積んだストック(慣性・非対称)。
#   → 見たい≠信頼: 誕生は魅力(話題)を上げるが評判は上げない。保全実績だけが評判を上げる。
RSpec.describe 'ニュース性' do
  catalog    = Zoo::Domain::Taxonomy::SpeciesCatalog
  policy     = Zoo::Domain::Operations::ReputationPolicy
  reputation = Zoo::Domain::Operations::Reputation
  attraction = Zoo::Domain::Operations::VisitorAttraction
  event      = Zoo::Domain::Operations::ReputationEvent
  money      = Zoo::Domain::Shared::Money

  fee = money.yen(2_000)
  rep = reputation.new(50)

  describe '信頼チャネル(評判を動かすニュース)' do
    # 露出ゼロ(来園なし)で評判を回す。体験ドリフトが消え、ニュース経路だけが残る。
    it 'カリスマ個体の死はニュースになること(来園ゼロでも評判が下がる)' do
      after = policy.after_day(reputation.new(80), experience: 100, exposure: 0,
                               events: [event::Death.new(cause: :old_age, charisma: 90)])
      expect(after.score).to be < 80
    end

    it '疫病の発生はニュースになること(来園ゼロでも評判が下がる)' do
      after = policy.after_day(reputation.new(80), experience: 100, exposure: 0,
                               events: [event::Outbreak.new])
      expect(after.score).to be < 80
    end

    it '絶滅危惧種の繁殖成功はニュースになること(保全実績で評判が上がる)' do
      breeding = event::ConservationBreeding.for(catalog.red_panda)
      after = policy.after_day(reputation.new(50), experience: 50, exposure: 0, events: [breeding])
      expect(after.score).to be > 50
    end
  end

  describe '話題チャネル(魅力を動かすニュース)' do
    it '幼獣の誕生はニュースになること(buzzで魅力が上がり集客が増える)' do
      animals = [build_adult(catalog.lion)]
      with_buzz    = attraction.expected_visitors(animals, rep, fee, buzz: 100)
      without_buzz = attraction.expected_visitors(animals, rep, fee, buzz: 0)
      expect(with_buzz).to be > without_buzz
    end
  end

  describe '何がニュースにならないか' do
    # 見たい≠信頼: ありふれた種の繁殖は話題(魅力)止まりで、信頼(評判)のニュースにはならない。
    it 'ありふれた種(LC)の繁殖は信頼チャネルのニュースにならないこと(保全実績ではない)' do
      expect(event::ConservationBreeding.for(catalog.koi)).to be_nil
    end

    it '日々の世話・清掃など通常運営はニュースにならないこと(信頼チャネルに何も足さない)' do
      routine  = policy.after_day(reputation.new(50), experience: 100, exposure: 0, events: [])
      with_news = policy.after_day(reputation.new(50), experience: 100, exposure: 0,
                                   events: [event::Death.new(cause: :unknown, charisma: 50)])
      expect(routine.score).to be > with_news.score
    end
  end
end
