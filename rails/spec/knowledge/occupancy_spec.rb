# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '区画の占有に対するルール(過密・収容可否)' do
  describe '過密' do
    it '体格に見合う広さなら過密にならないこと' do
      savanna = pen('サバンナ', capacity: 4, temp: 28)
      house_without_validation(build_adult(:lion, name: 'A'), savanna)
      house_without_validation(build_adult(:lion, name: 'B'), savanna)

      expect(Occupancy.of(savanna).overcrowded?).to be(false)
    end

    it '必要面積の合計が区画の広さを超えると過密になること' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)
      house_without_validation(build_adult(:african_elephant), savanna)

      expect(Occupancy.of(savanna).overcrowded?).to be(true)
    end
  end

  describe '収容可否のルール' do
    it '定員に達した区画にはこれ以上収容できないこと' do
      savanna = pen('サバンナ', capacity: 1)
      house_without_validation(build_adult(:lion, name: '先客'), savanna)

      expect { house(build_adult(:lion, name: '新入り'), savanna) }
        .to raise_error(Errors::HousingNotAllowed, /定員/)
    end

    it '適温域に合わない区画には収容できないこと' do
      tropics = pen('熱帯', temp: 35)

      expect { house(build_adult(:emperor_penguin), tropics) }
        .to raise_error(Errors::HousingNotAllowed, /適応/)
    end

    it '捕食関係にある種は同居できないこと' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)
      house_without_validation(build_adult(:lion, name: 'ライオン'), savanna)

      expect { house(build_adult(:african_elephant), savanna) }
        .to raise_error(Errors::HousingNotAllowed, /捕食/)
    end

    it '死亡した動物は収容できないこと' do
      savanna = pen('サバンナ')
      carcass = build_adult(:lion).tap { |a| a.die(cause: :illness) }

      expect { house(carcass, savanna) }
        .to raise_error(Errors::HousingNotAllowed, /死亡/)
    end

    it 'ルールに反しなければ収容できること' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)

      expect { house(build_adult(:lion), savanna) }.not_to raise_error
    end
  end
end
