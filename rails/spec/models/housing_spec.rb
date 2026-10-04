# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Housing do
  let(:lion) { build_adult(:lion, name: 'レオ') }
  let(:savanna) { pen('サバンナ', capacity: 4, temp: 28) }

  describe '.house' do
    it '個体と区画から入居イベントを作り、区画idを導出すること' do
      housing = house(lion, savanna)
      expect(housing.animal).to eq(lion)
      expect(housing.enclosure).to eq(savanna)
      expect(housing.enclosure_id).to eq(savanna.id)
    end

    it '#to_s が収容を表すこと' do
      expect(house(lion, savanna).to_s).to eq('レオを収容')
    end
  end

  it '構築後は animal=/enclosure= を外部から呼べないこと(id参照のみで、集約を後から差し替えられない)' do
    housing = house(lion, savanna)
    expect { housing.animal = build_adult(:lion, name: '別の個体') }.to raise_error(NoMethodError)
    expect { housing.enclosure = pen('別区画') }.to raise_error(NoMethodError)
  end

  describe '#admission_violation!(Housing.house経由)' do
    let(:zebra) { build_adult(:grevys_zebra) }

    it '違反がなければ例外を投げないこと' do
      expect { house(lion, savanna) }.not_to raise_error
    end

    it '死亡個体は HousingNotAllowed(死亡) であること' do
      dead = build_adult(:lion).tap(&:die)
      expect { house(dead, savanna) }.to raise_error(Errors::HousingNotAllowed, /死亡/)
    end

    it '満員だと HousingNotAllowed(定員) であること' do
      full = pen('小屋', capacity: 1, temp: 28)
      house_without_validation(build_adult(:lion, name: '先住'), full)
      expect { house(lion, full) }.to raise_error(Errors::HousingNotAllowed, /定員/)
    end

    it '適温に合わない個体は HousingNotAllowed(適応) であること' do
      cold = pen('極地', capacity: 4, temp: -10)
      expect { house(zebra, cold) }.to raise_error(Errors::HousingNotAllowed, /適応/)
    end

    it '捕食関係の異種との同居は HousingNotAllowed(捕食) であること' do
      house_without_validation(zebra, savanna)
      expect { house(lion, savanna) }.to raise_error(Errors::HousingNotAllowed, /捕食/)
    end

    it '単独性の同種との同居は HousingNotAllowed(単独性) であること' do
      cold = pen('極地', capacity: 4, temp: -10)
      house_without_validation(build_adult(:polar_bear, name: '先住'), cold)
      expect { house(build_adult(:polar_bear, name: '白'), cold) }
        .to raise_error(Errors::HousingNotAllowed, /単独性/)
    end

    it '適温域が両立しない種との同居は HousingNotAllowed(適温域) であること' do
      house_without_validation(build_adult(:emperor_penguin, name: '先住'), savanna)
      tortoise = build_adult(:galapagos_tortoise, name: 'カメ')
      expect { house(tortoise, savanna) }.to raise_error(Errors::HousingNotAllowed, /適温域/)
    end

    it '複数の違反を一度にまとめて報告すること' do
      full = pen('小屋', capacity: 1, temp: 28)
      house_without_validation(build_adult(:lion, name: '先住'), full)
      dead = build_adult(:lion).tap(&:die)
      expect { house(dead, full) }.to raise_error(Errors::HousingNotAllowed, /死亡.*定員/)
    end
  end
end

RSpec.describe Releasing do
  let(:lion) { build_adult(:lion, name: 'レオ') }
  let(:savanna) { pen('サバンナ', capacity: 4, temp: 28) }

  describe '.release' do
    it '閉じる入居イベントを持ち、個体はそこから導出されること' do
      housing = house(lion, savanna)
      releasing = Releasing.release(housing: housing)
      expect(releasing.closes_housing).to eq(housing)
      expect(releasing.animal).to eq(lion)
    end

    it '#to_s が解放を表すこと' do
      housing = house(lion, savanna)
      expect(Releasing.release(housing: housing).to_s).to eq('レオを解放')
    end

    it '解放後は現在の収容として扱われなくなること' do
      housing = house(lion, savanna)
      Releasing.release(housing: housing)
      expect(Housing.current_for(lion)).to be_nil
      expect(Housing.occupants_of(savanna)).not_to include(lion)
    end
  end

  it '構築後は closes_housing= を外部から呼べないこと' do
    housing = house(lion, savanna)
    releasing = Releasing.release(housing: housing)
    another_housing = house(build_adult(:lion, name: '別'), pen('別区画'))
    expect { releasing.closes_housing = another_housing }.to raise_error(NoMethodError)
  end
end
