# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Contagion do
  let(:pride) do
    build(:enclosure, name: '丘', capacity: 6)
  end

  def occupancy(occupants)
    Occupancy.new(enclosure: pride, occupants: occupants)
  end

  describe '#spread' do
    it '感染源がいなければ誰も発病せず、空配列を返すこと' do
      occupants = [build(:animal, name: 'A'), build(:animal, name: 'B')]

      expect(described_class.new(pride, occupancy(occupants)).spread).to eq([])
    end

    it '新たに発病した個体だけを返すこと' do
      carrier = build(:animal, name: '感染源')
      carrier.fall_ill(IllnessCatalog.cold)
      healthy = build(:animal, name: '健康')

      expect(described_class.new(pride, occupancy([carrier, healthy])).spread).to contain_exactly(healthy)
    end
  end
end
