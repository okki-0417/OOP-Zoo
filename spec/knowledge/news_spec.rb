# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'ニュース性' do
  catalog    = Zoo::Domain::SpeciesCatalog
  reputation = Zoo::Domain::Zoo::Reputation
  attraction = Zoo::Domain::VisitorAttraction
  event      = Zoo::Domain::ReputationEvent
  money      = Zoo::Domain::Shared::Money

  fee = money.yen(2_000)
  rep = reputation.new(50).factor

  describe '信頼チャネル(評判を動かすニュース)' do
    it 'カリスマ個体の死はニュースになること(来園ゼロでも評判が下がる)' do
      after = reputation.new(80).after_day(experience: 100, exposure: 0,
                                           events: [event::Death.new(cause: :old_age, charisma: 90)])
      expect(after.score).to be < 80
    end

    it '疫病の発生はニュースになること(来園ゼロでも評判が下がる)' do
      after = reputation.new(80).after_day(experience: 100, exposure: 0,
                                           events: [event::Outbreak.new])
      expect(after.score).to be < 80
    end

    it '絶滅危惧種の繁殖成功はニュースになること(保全実績で評判が上がる)' do
      breeding = event::ConservationBreeding.for(catalog.red_panda)
      after = reputation.new(50).after_day(experience: 50, exposure: 0, events: [breeding])
      expect(after.score).to be > 50
    end
  end

  describe '話題チャネル(見応えを動かすニュース)' do
    it '幼獣の誕生はニュースになること(buzzで見応えが上がり集客が増える)' do
      animals = [build_adult(catalog.lion)]
      with_buzz    = attraction.expected_visitors(animals, rep, fee, buzz: 100)
      without_buzz = attraction.expected_visitors(animals, rep, fee, buzz: 0)
      expect(with_buzz).to be > without_buzz
    end
  end

  describe '何がニュースにならないか' do
    it 'ありふれた種(LC)の繁殖は信頼チャネルのニュースにならないこと(保全実績ではない)' do
      expect(event::ConservationBreeding.for(catalog.koi)).to be_nil
    end

    it '日々の世話・清掃など通常運営はニュースにならないこと(信頼チャネルに何も足さない)' do
      routine   = reputation.new(50).after_day(experience: 100, exposure: 0, events: [])
      with_news = reputation.new(50).after_day(experience: 100, exposure: 0,
                                               events: [event::Death.new(cause: :unknown, charisma: 50)])
      expect(routine.score).to be > with_news.score
    end
  end
end
