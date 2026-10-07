# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Relieving do
  let(:keeper) { build(:keeper, name: '田中') }
  let(:enclosure) do
    build(:enclosure, name: 'サバンナ')
  end
  let(:relieving) { described_class.new(keeper:, enclosure:) }

  describe '#violation!' do
    it '田中がサバンナを担当していれば例外を出さないこと' do
      keeper.enclosures << enclosure
      expect { relieving.violation! }.not_to raise_error
    end

    it '田中がサバンナを担当していなければ ReliefNotAllowed(田中…サバンナ…退任) を出すこと' do
      expect { relieving.violation! }
        .to raise_error(Errors::ReliefNotAllowed, /田中.*サバンナ.*退任/)
    end
  end

  describe '#perform' do
    it '担当していれば田中の担当からサバンナが外れ、in_charge_of? が false になること' do
      keeper.enclosures << enclosure
      relieving.perform
      expect(keeper.in_charge_of?(enclosure)).to be(false)
    end

    it '保存済みの担当を外すと assignments の行が消えること' do
      keeper.save!
      enclosure.save!
      keeper.enclosures << enclosure
      expect { relieving.perform }.to change(Assignment, :count).from(1).to(0)
    end

    it '担当していなければ ReliefNotAllowed を出すこと' do
      expect { relieving.perform }.to raise_error(Errors::ReliefNotAllowed)
    end
  end

  it '生成後は frozen であること' do
    expect(relieving).to be_frozen
  end

  describe '#to_s' do
    it '担当から外す の形で表されること' do
      expect(relieving.to_s).to eq('田中をサバンナの担当から外す')
    end
  end
end
