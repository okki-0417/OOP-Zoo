# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Contagion do
  catalog   = Zoo::Domain::SpeciesCatalog
  illnesses = Zoo::Domain::IllnessCatalog

  let(:pride) do
    Zoo::Domain::Enclosure.new(
      name: '丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 6
    )
  end

  describe '#spread' do
    it '感染源がいなければ誰も発病せず、空配列を返すこと' do
      occupants = [build_adult(catalog.lion, name: 'A'), build_adult(catalog.lion, name: 'B')]

      expect(described_class.new(pride, occupants).spread).to eq([])
    end

    it '新たに発病した個体だけを返すこと' do
      carrier = build_adult(catalog.lion, name: '感染源')
      carrier.fall_ill(illnesses.cold)
      healthy = build_adult(catalog.lion, name: '健康')

      expect(described_class.new(pride, [carrier, healthy]).spread).to contain_exactly(healthy)
    end
  end
end
