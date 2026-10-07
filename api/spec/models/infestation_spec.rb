# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Infestation do
  def pen
    build(:enclosure, name: '丘', capacity: 6)
  end

  def occupancy(enclosure, occupants)
    Occupancy.new(enclosure: enclosure, occupants: occupants)
  end

  describe '#spread' do
    it '清潔なエリアでは誰も発病せず [] を返すこと' do
      enclosure = pen
      lion = build(:animal)

      expect(described_class.new(enclosure, occupancy(enclosure, [lion])).spread).to eq([])
      expect(lion).not_to be_sick
    end

    it 'soil(80)で不潔だと感受性個体が寄生虫に発病し、発病個体を返すこと' do
      enclosure = pen
      enclosure.soil(80)
      healthy = build(:animal)

      result = described_class.new(enclosure, occupancy(enclosure, [healthy])).spread

      expect(result).to contain_exactly(healthy)
      expect(healthy).to be_sick
    end

    it '既に病気の個体(感受性なし)は不潔でも発病対象にならず [] を返すこと' do
      enclosure = pen
      enclosure.soil(80)
      already = build(:animal)
      already.fall_ill(IllnessCatalog.cold)

      expect(described_class.new(enclosure, occupancy(enclosure, [already])).spread).to eq([])
    end
  end
end
