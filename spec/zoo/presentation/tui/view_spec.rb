# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Presentation::Tui::View do
  shared     = Zoo::Domain::Shared
  read_models = Zoo::Application::ReadModels

  let(:view) { described_class.new }

  describe '#dashboard' do
    it '在園数・残高・評判・エリア/職員数を枠内に描画すること' do
      stats = read_models::ZooStatistics.new(
        population: 3, species_count: 2, threatened_count: 1, births: 1,
        deaths_by_cause: {}, revenue: shared::Money.yen(50_000),
        balance: shared::Balance.new(148_500), reputation: 52
      )

      panel = view.dashboard(stats, enclosures: 4, staff: 3)

      expect(panel).to include('在園 3頭')
      expect(panel).to include('¥148,500')
      expect(panel).to include('52/100')
      expect(panel).to include('エリア 4')
      expect(panel).to include('職員 3')
    end

    it '残高が赤字なら「赤字」と表示すること' do
      stats = read_models::ZooStatistics.new(
        population: 0, species_count: 0, threatened_count: 0, births: 0,
        deaths_by_cause: {}, revenue: shared::Money.zero,
        balance: shared::Balance.new(-5_000), reputation: 10
      )

      expect(view.dashboard(stats, enclosures: 1, staff: 0)).to include('赤字')
    end
  end

  describe '#animal_table' do
    it '個体がいなければ「個体はいません」を返すこと' do
      expect(view.animal_table([])).to eq('個体はいません')
    end

    it '個体があれば名前・種を含む表を描画すること' do
      rows = [read_models::AnimalSummary.new(
        id: 'abcdef123456', name: 'レオ', species: 'ライオン', alive: true,
        health: 100, max_health: 100, ailing: false
      )]

      table = view.animal_table(rows)

      expect(table).to include('レオ', 'ライオン')
    end
  end

  describe '#enclosure_table' do
    it 'エリアが無ければ「エリアはありません」を返すこと' do
      expect(view.enclosure_table([])).to eq('エリアはありません')
    end

    it 'エリアがあれば名前と収容数/定員を描画すること' do
      rows = [read_models::EnclosureSummary.new(
        id: 'abcdef123456', name: 'サバンナ', population: 2, capacity: 6, cleanliness: 80, filthy: false
      )]

      expect(view.enclosure_table(rows)).to include('サバンナ', '2/6')
    end
  end

  describe '#enclosure_detail' do
    it '収容数・清潔度・収容個体名を描画すること' do
      profile = read_models::EnclosureProfile.new(
        id: 'e1', name: 'サバンナ', capacity: 6, population: 1, cleanliness: 100, filthy: false,
        occupants: [read_models::AnimalSummary.new(
          id: 'a1', name: 'シマオ', species: 'グレビーシマウマ', alive: true,
          health: 100, max_health: 100, ailing: false
        )]
      )

      panel = view.enclosure_detail(profile)

      expect(panel).to include('サバンナ', '1/6', 'シマオ')
    end
  end

  describe '#threatened_table' do
    it '絶滅危惧種がいなければメッセージを返すこと' do
      expect(view.threatened_table([])).to eq('展示中の絶滅危惧種はいません')
    end

    it '種・保全状況・頭数を描画すること' do
      rows = [read_models::ExhibitedSpecies.new(name_ja: 'グレビーシマウマ', status_code: 'EN', status_label: '絶滅危惧', count: 2)]

      expect(view.threatened_table(rows)).to include('グレビーシマウマ', 'EN')
    end
  end

  describe '#deceased_table' do
    it '死亡が無ければ「死亡記録はありません」を返すこと' do
      expect(view.deceased_table([])).to eq('死亡記録はありません')
    end

    it '死因を和訳して描画すること(老衰)' do
      records = [read_models::DeceasedRecord.new(name: '長老', species: 'ニシキゴイ', cause: :old_age)]

      expect(view.deceased_table(records)).to include('長老', '老衰')
    end
  end

  describe '#report' do
    it '死因別の死亡を集計して描画すること(老衰1・餓死2)' do
      stats = read_models::ZooStatistics.new(
        population: 5, species_count: 3, threatened_count: 2, births: 1,
        deaths_by_cause: { old_age: 1, starvation: 2 }, revenue: shared::Money.yen(0),
        balance: shared::Balance.zero, reputation: 50
      )

      expect(view.report(stats)).to include('老衰1', '餓死2')
    end
  end
end
