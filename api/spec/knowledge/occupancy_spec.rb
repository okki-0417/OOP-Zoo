# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '区画の占有に対するルール(過密・収容可否)' do
  def pen(name = '区画', capacity: 4, temp: 25)
    Enclosure.new(
      name: name, temperature: Temperature.celsius(temp), capacity: capacity
    )
  end

  describe '過密' do
    it '体格に見合う広さなら過密にならないこと' do
      savanna = pen('サバンナ', capacity: 4, temp: 28)
      occupants = [build_adult(SpeciesCatalog.lion, name: 'A'), build_adult(SpeciesCatalog.lion, name: 'B')]

      expect(build_occupancy(savanna, occupants).overcrowded?).to be(false)
    end

    it '必要面積の合計が区画の広さを超えると過密になること' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)

      expect(build_occupancy(savanna, [build_adult(SpeciesCatalog.african_elephant)]).overcrowded?).to be(true)
    end
  end

  describe '収容可否のルール' do
    def admit!(animal, enclosure, residents = [])
      occupancy = build_occupancy(enclosure, residents)
      Housing.new(animal: animal, enclosure: enclosure, occupancy: occupancy).admission_violation!
    end

    it '定員に達した区画にはこれ以上収容できないこと' do
      savanna = pen('サバンナ', capacity: 1)
      resident = build_adult(SpeciesCatalog.lion, name: '先客')

      expect { admit!(build_adult(SpeciesCatalog.lion, name: '新入り'), savanna, [resident]) }
        .to raise_error(Errors::HousingNotAllowed, /定員/)
    end

    it '適温域に合わない区画には収容できないこと' do
      tropics = pen('熱帯', temp: 35)

      expect { admit!(build_adult(SpeciesCatalog.emperor_penguin), tropics) }
        .to raise_error(Errors::HousingNotAllowed, /適応/)
    end

    it '捕食関係にある種は同居できないこと' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)
      resident = build_adult(SpeciesCatalog.lion, name: 'ライオン')

      expect { admit!(build_adult(SpeciesCatalog.african_elephant), savanna, [resident]) }
        .to raise_error(Errors::HousingNotAllowed, /捕食/)
    end

    it '死亡した動物は収容できないこと' do
      savanna = pen('サバンナ')
      carcass = build_adult(SpeciesCatalog.lion).tap { |a| a.die(cause: :illness) }

      expect { admit!(carcass, savanna) }
        .to raise_error(Errors::HousingNotAllowed, /死亡/)
    end

    it 'ルールに反しなければ収容できること' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)

      expect { admit!(build_adult(SpeciesCatalog.lion), savanna) }.not_to raise_error
    end
  end
end
