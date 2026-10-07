# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Contagion do
  let(:pride) do
    Enclosure.new(
      name: '丘', temperature: Temperature.celsius(28), capacity: 6
    )
  end

  def occupancy(occupants)
    build_occupancy(pride, occupants)
  end

  describe '#spread' do
    it '感染源がいなければ誰も発病せず、空配列を返すこと' do
      occupants = [build_adult(SpeciesCatalog.lion, name: 'A'), build_adult(SpeciesCatalog.lion, name: 'B')]

      expect(described_class.new(pride, occupancy(occupants)).spread).to eq([])
    end

    it '新たに発病した個体だけを返すこと' do
      carrier = build_adult(SpeciesCatalog.lion, name: '感染源')
      carrier.fall_ill(IllnessCatalog.cold)
      healthy = build_adult(SpeciesCatalog.lion, name: '健康')

      expect(described_class.new(pride, occupancy([carrier, healthy])).spread).to contain_exactly(healthy)
    end
  end
end
