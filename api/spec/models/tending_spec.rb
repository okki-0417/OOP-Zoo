# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Tending do
  let(:keeper) { build(:keeper, name: '田中') }
  let(:enclosure) do
    build(:enclosure, name: 'サバンナ')
  end
  let(:lion) { build(:animal) }
  let(:penguin) { build(:animal, species: SpeciesCatalog.emperor_penguin) }

  def tending(*occupants)
    described_class.new(keeper:, enclosure:, occupancy: Occupancy.new(enclosure: enclosure, occupants: occupants))
  end

  describe '#violation!' do
    it '空のエリアで未担当なら例外を出さないこと' do
      expect { tending.violation! }.not_to raise_error
    end

    it '専門外の綱が混ざると AssignmentNotAllowed を綱ラベル付きで出すこと' do
      expect { tending(lion, penguin).violation! }
        .to raise_error(Errors::AssignmentNotAllowed, /田中.*サバンナ.*鳥類/)
    end

    it '専門の綱だけなら例外を出さないこと' do
      expect { tending(lion).violation! }.not_to raise_error
    end

    it '田中がすでにサバンナを担当していれば二重配属として AssignmentNotAllowed を出すこと' do
      keeper.enclosures << enclosure
      expect { tending.violation! }
        .to raise_error(Errors::AssignmentNotAllowed, /田中.*すでに.*サバンナ/)
    end

    it '他の飼育員だけが担当しているなら例外を出さないこと' do
      build(:keeper, name: '鈴木').enclosures << enclosure
      expect { tending.violation! }.not_to raise_error
    end
  end

  describe '#perform' do
    it '違反がなければ田中がサバンナを担当する(in_charge_of? が true)こと' do
      tending(lion).perform
      expect(keeper.in_charge_of?(enclosure)).to be(true)
    end

    it '保存済みの飼育員とエリアなら assignments に1行保存されること' do
      keeper.save!
      enclosure.save!
      expect { tending(lion).perform }.to change(Assignment, :count).from(0).to(1)
    end

    it '違反があれば AssignmentNotAllowed を出し、担当にならないこと' do
      expect { tending(penguin).perform }.to raise_error(Errors::AssignmentNotAllowed)
      expect(keeper.in_charge_of?(enclosure)).to be(false)
    end
  end

  it '生成後は frozen であること' do
    expect(tending).to be_frozen
  end

  describe '#to_s' do
    it '名前を配属 の形で表されること' do
      expect(tending.to_s).to eq('田中をサバンナに配属')
    end
  end
end
