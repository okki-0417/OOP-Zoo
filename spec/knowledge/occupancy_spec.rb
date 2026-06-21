# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '区画の占有に対するルール(過密・収容可否)' do
  catalog = Zoo::Domain::SpeciesCatalog

  def pen(name = '区画', capacity: 4, temp: 25)
    Zoo::Domain::Enclosure.new(
      name: name, temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: capacity
    )
  end

  describe '過密' do
    it '体格に見合う広さなら過密にならないこと' do
      savanna = pen('サバンナ', capacity: 4, temp: 28)
      occupants = [build_adult(catalog.lion, name: 'A'), build_adult(catalog.lion, name: 'B')]

      expect(Zoo::Domain::Occupancy.new(savanna, occupants).overcrowded?).to be(false)
    end

    it '必要面積の合計が区画の広さを超えると過密になること' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)

      expect(Zoo::Domain::Occupancy.new(savanna, [build_adult(catalog.african_elephant)]).overcrowded?).to be(true)
    end
  end

  describe '収容可否のルール' do
    def admit!(animal, enclosure, residents = [])
      occupancy = Zoo::Domain::Occupancy.new(enclosure, residents)
      Zoo::Domain::Housing.new(animal: animal, enclosure: enclosure, occupancy: occupancy).admission_violation!
    end

    it '定員に達した区画にはこれ以上収容できないこと' do
      savanna = pen('サバンナ', capacity: 1)
      resident = build_adult(catalog.lion, name: '先客')

      expect { admit!(build_adult(catalog.lion, name: '新入り'), savanna, [resident]) }
        .to raise_error(Zoo::Domain::Errors::HousingNotAllowed, /定員/)
    end

    it '適温域に合わない区画には収容できないこと' do
      tropics = pen('熱帯', temp: 35)

      expect { admit!(build_adult(catalog.emperor_penguin), tropics) }
        .to raise_error(Zoo::Domain::Errors::HousingNotAllowed, /適応/)
    end

    it '捕食関係にある種は同居できないこと' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)
      resident = build_adult(catalog.lion, name: 'ライオン')

      expect { admit!(build_adult(catalog.african_elephant), savanna, [resident]) }
        .to raise_error(Zoo::Domain::Errors::HousingNotAllowed, /捕食/)
    end

    it '死亡した動物は収容できないこと' do
      savanna = pen('サバンナ')
      carcass = build_adult(catalog.lion).tap { |a| a.die(cause: :illness) }

      expect { admit!(carcass, savanna) }
        .to raise_error(Zoo::Domain::Errors::HousingNotAllowed, /死亡/)
    end

    it 'ルールに反しなければ収容できること' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)

      expect { admit!(build_adult(catalog.lion), savanna) }.not_to raise_error
    end
  end
end
