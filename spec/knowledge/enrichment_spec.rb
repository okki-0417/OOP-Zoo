# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '環境エンリッチメントと常同行動' do

  def savanna(temp = 28)
    Zoo::Domain::Enclosure.new(
      name: 'サバンナ', temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: 4
    )
  end

  def with_company(enclosure)
    lion = Zoo::Domain::SpeciesCatalog.lion
    occupants = [
      build_adult(lion, name: 'A'),
      build_adult(lion, name: 'B', sex: Zoo::Domain::Animal::Sex.female)
    ]
    [enclosure, occupants]
  end

  describe '刺激の枯渇' do
    context '刺激が十分なエリアにいると' do
      it '退屈せず、良好な飼育ならストレスが和らぐこと' do
        enclosure, occupants = with_company(savanna)
        occupant = occupants.first

        expect(welfare_of(occupant, enclosure, occupants).daily_stress).to be < 0
      end
    end

    context '刺激が枯れた(殺風景な)エリアにいると' do
      it '退屈による常同行動でストレスが増すこと' do
        enclosure, occupants = with_company(savanna)
        enclosure.deplete_enrichment(100)
        occupant = occupants.first

        expect(welfare_of(occupant, enclosure, occupants).daily_stress).to be > 0
      end
    end
  end

  describe '刺激の補充' do
    context '枯れたエリアに新たな刺激を補充すると' do
      it '再び退屈しなくなること' do
        enclosure, = with_company(savanna)
        enclosure.deplete_enrichment(100)
        enclosure.enrich(100)

        expect(enclosure).not_to be_barren
      end
    end
  end

  describe '放置による刺激の減衰' do
    it '日々の暮らしで刺激は少しずつ薄れること' do
      enclosure, occupants = with_company(savanna)
      expect { Zoo::Domain::EnclosureDay.new(enclosure, Zoo::Domain::Occupancy.new(enclosure, occupants)).run }
        .to change { enclosure.enrichment.level }.by(-Zoo::Domain::EnclosureDay::ENRICHMENT_DECAY_PER_DAY)
    end
  end
end
