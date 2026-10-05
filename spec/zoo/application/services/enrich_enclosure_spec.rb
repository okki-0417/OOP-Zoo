# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::EnrichEnclosure do
  let(:keeper) { build_keeper }
  let(:hill) do
    Zoo::Domain::Enclosure.new(name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(24), capacity: 4)
  end
  let(:keepers) { Factory::KeeperRepository.build([keeper]) }
  let(:enclosures) { Factory::EnclosureRepository.build([hill]) }

  def enrich(keeper_id: keeper.id, enclosure_id: hill.id)
    command = Factory::EnrichEnclosureCommand.with_bind(keeper_id:, enclosure_id:, keepers:, enclosures:)
    described_class.new(command:).call
  end

  describe '#call' do
    it '刺激度40のエリアを100に戻し、EnclosureProfile(enrichment=100・barren=false)を返して飼育員の勤務時間30分を保存すること' do
      hill.deplete_enrichment(60)

      expect(enrich.value).to have_attributes(enrichment: 100, barren: false)
      expect(keepers.find(keeper.id).worked_minutes).to eq(30)
    end

    it "存在しない keeper_id / enclosure_id 'missing' はそれぞれ KeeperNotFound / EnclosureNotFound になること" do
      expect(enrich(keeper_id: 'missing').error).to be_a(Zoo::Application::Errors::KeeperNotFound)
      expect(enrich(enclosure_id: 'missing').error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end

    it '勤務時間の残っていない飼育員は WorkNotAllowed の失敗 Result になること' do
      keeper.clock_in(480)
      expect(enrich.error).to be_a(Zoo::Domain::Errors::WorkNotAllowed)
    end
  end
end
