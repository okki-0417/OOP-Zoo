# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::MakeRounds do
  catalog = Zoo::Domain::SpeciesCatalog

  let(:keeper) { build_keeper(Zoo::Domain::TaxonClass.mammal) }
  let(:hill) do
    Zoo::Domain::Enclosure.new(name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(24), capacity: 4)
  end
  let(:leo) { build_adult(catalog.lion, name: 'レオ').get_hungrier(60) }
  let(:animals) { Factory::AnimalRepository.build([leo]) }
  let(:enclosures) { Factory::EnclosureRepository.build([hill]) }
  let(:keepers) { Factory::KeeperRepository.build([keeper]) }

  def make_rounds(keeper_id: keeper.id, tendings: [Zoo::Domain::Tending.new(keeper:, enclosure: hill)])
    command = Factory::MakeRoundsCommand.with_bind(
      keeper_id:, keepers:, animals:, enclosures:,
      housings: Factory::HousingRepository.build([housed(leo, hill)]),
      assignments: Factory::AssignmentRepository.build(tendings)
    )
    described_class.new(command:).call
  end

  describe '#call' do
    it '担当エリアを見回ってレオに給餌し、RoundsReport に給餌した名前と残り勤務時間(470分)を返すこと' do
      report = make_rounds.value

      expect(report).to have_attributes(keeper_name: '飼育員', remaining_minutes: 470)
      expect(report.rounds).to eq([{ enclosure: Zoo::Application::ReadModels::StaffRef.of(hill), fed: ['レオ'],
                                     skipped: [], cleaned: false, enriched: false }])
    end

    it '給餌した個体と勤務時間を使った飼育員を保存すること' do
      make_rounds

      expect(animals.find(leo.id).hunger_level).to eq(0)
      expect(keepers.find(keeper.id).worked_minutes).to eq(10)
    end

    it '担当エリアがなければ rounds は空で、勤務時間も使わないこと' do
      expect(make_rounds(tendings: []).value).to have_attributes(rounds: [], remaining_minutes: 480)
    end

    it "存在しない keeper_id 'missing' は KeeperNotFound の失敗 Result を返すこと" do
      expect(make_rounds(keeper_id: 'missing').error).to be_a(Zoo::Application::Errors::KeeperNotFound)
    end
  end
end
