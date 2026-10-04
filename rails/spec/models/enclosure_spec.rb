# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Enclosure do
  let(:savanna) { pen('アフリカサバンナ', capacity: 3, temp: 30) }

  it '広さを指定しなければ定員×100m²になること' do
    expect(savanna.area_sqm).to eq(300)
  end

  describe '.construction_cost' do
    it '基本建設費＋定員×1枠単価で算出すること(定員5=80,000円)' do
      expect(described_class.construction_cost(capacity: 5)).to eq(Money.yen(80_000))
    end

    it '空調設備は建設費を上乗せすること' do
      expect(described_class.construction_cost(capacity: 5, climate_controlled: true))
        .to be > described_class.construction_cost(capacity: 5)
    end
  end

  describe '.build' do
    it '定員が1未満だと保存できないこと' do
      expect { described_class.build(name: '小屋', temperature: Temperature.celsius(20), capacity: 0) }
        .to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '清潔さ' do
    it 'soil で汚れ filthy? になり、clean で清掃できること' do
      savanna.soil(100)
      expect(savanna).to be_filthy
      savanna.clean(100)
      expect(savanna).not_to be_filthy
    end

    it '清潔度を保存して再読み込みしても保たれること' do
      savanna.soil(60)
      savanna.save!
      expect(Enclosure.find(savanna.id).cleanliness_level).to eq(40)
    end
  end

  describe '環境エンリッチメント' do
    it '新設エリアは刺激が満ちており殺風景でないこと' do
      expect(savanna).not_to be_barren
    end

    it 'deplete_enrichment で刺激が枯れると barren? になること' do
      savanna.deplete_enrichment(100)
      expect(savanna).to be_barren
    end

    it 'enrich で刺激を補充すると barren? が解けること' do
      savanna.deplete_enrichment(100)
      savanna.enrich(100)
      expect(savanna).not_to be_barren
    end

    it 'エンリッチメントを保存して再読み込みしても保たれること(旧SQLite実装での永続化漏れの解消)' do
      savanna.deplete_enrichment(80)
      savanna.save!
      expect(Enclosure.find(savanna.id)).to be_barren
    end
  end
end
