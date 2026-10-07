# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::DischargeKeeper do
  let!(:keeper) { Zoo::Domain::Keeper.create!(name: '田中', specialties: [Zoo::Domain::TaxonClass.mammal]) }
  let!(:enclosure) { create_enclosure(name: 'サバンナ') }

  def discharge(keeper_id: keeper.id, enclosure_id: enclosure.id)
    command = Zoo::Application::Commands::DischargeKeeperCommand.new(keeper_id:, enclosure_id:)
    described_class.new(command:).call
  end

  describe '#call' do
    it '担当中のエリアを退任すると success になり現在の担当から外れること' do
      keeper.enclosures << enclosure

      expect(discharge.success?).to be(true)
      expect(keeper.reload.enclosures).to be_empty
      expect(Zoo::Domain::Assignment.count).to eq(0)
    end

    it '担当していないエリアの退任は failure で error が AssignmentNotFound となること' do
      expect(discharge.error).to be_a(Zoo::Application::Errors::AssignmentNotFound)
    end

    it '存在しない keeper_id "missing" を渡すと failure で error が KeeperNotFound となること' do
      expect(discharge(keeper_id: 'missing').error).to be_a(Zoo::Application::Errors::KeeperNotFound)
    end

    it '存在しない enclosure_id "missing" を渡すと failure で error が EnclosureNotFound となること' do
      expect(discharge(enclosure_id: 'missing').error).to be_a(Zoo::Application::Errors::EnclosureNotFound)
    end
  end
end
