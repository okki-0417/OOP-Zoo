# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '収容(どの動物がどの区画にいるか)' do
  catalog = Zoo::Domain::SpeciesCatalog

  def housings
    @housings ||= []
  end

  def occupancy
    Zoo::Domain::Occupancy.new(housings)
  end

  def pen(name = '区画', capacity: 4, temp: 25)
    Zoo::Domain::Enclosure.new(
      name: name, temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: capacity
    )
  end

  def house(animal, enclosure, day: 0)
    housings << Zoo::Domain::Housing.record(animal: animal, enclosure: enclosure, occurred_on: day)
    animal
  end

  def release(animal, day: 0)
    current = Zoo::Domain::Occupancy.new(housings).current_housing_of(animal)
    housings << Zoo::Domain::Release.of(current, occurred_on: day)
    animal
  end

  describe '収容履歴から現在の収容を求める' do
    it '収容された動物はその区画の収容動物に含まれること' do
      savanna = pen('サバンナ')
      simba = house(build_adult(catalog.lion, name: 'シンバ'), savanna)

      expect(occupancy.occupants_of(savanna)).to contain_exactly(simba)
    end

    it 'まだ収容されていない区画の収容動物は空であること' do
      expect(occupancy.occupants_of(pen('空き区画'))).to be_empty
    end

    it '転居すると移動先が勝ち、元の区画の収容動物には含まれなくなること' do
      old_pen = pen('旧区画')
      new_pen = pen('新区画')
      nala = house(build_adult(catalog.lion, name: 'ナラ'), old_pen, day: 1)
      house(nala, new_pen, day: 2)

      expect(occupancy.occupants_of(old_pen)).to be_empty
      expect(occupancy.occupants_of(new_pen)).to contain_exactly(nala)
    end

    it '解放するとどの区画にも収容されていないことになること' do
      savanna = pen('サバンナ')
      simba = house(build_adult(catalog.lion, name: 'シンバ'), savanna, day: 1)
      release(simba, day: 3)

      expect(occupancy.occupants_of(savanna)).to be_empty
      expect(occupancy.enclosure_id_of(simba)).to be_nil
    end

    it '同じ日に複数のイベントがあるとき、後から記録したイベントが勝つこと' do
      old_pen = pen('旧区画')
      new_pen = pen('新区画')
      zazu = house(build_adult(catalog.lion, name: 'ザズー'), old_pen, day: 5)
      house(zazu, new_pen, day: 5)

      expect(occupancy.occupants_of(new_pen)).to contain_exactly(zazu)
    end

    it '死亡した動物は収容動物にも収容数にも含まれないこと' do
      savanna = pen('サバンナ')
      simba = house(build_adult(catalog.lion, name: 'シンバ'), savanna)
      simba.die(cause: :illness)

      expect(occupancy.occupants_of(savanna)).to be_empty
      expect(occupancy.population_of(savanna)).to eq(0)
    end
  end

  describe '収容数と空き' do
    it '定員から現在の収容数を引いた数が空き枠になること' do
      savanna = pen('サバンナ', capacity: 3)
      house(build_adult(catalog.lion, name: 'A'), savanna)
      house(build_adult(catalog.lion, name: 'B'), savanna)

      expect(occupancy.population_of(savanna)).to eq(2)
      expect(occupancy.vacancies_in(savanna)).to eq(1)
    end

    it '空き枠が無くなると満員になること' do
      savanna = pen('サバンナ', capacity: 1)
      house(build_adult(catalog.lion, name: 'A'), savanna)

      expect(occupancy.full?(savanna)).to be(true)
    end
  end

  describe '過密' do
    it '体格に見合う広さなら過密にならないこと' do
      savanna = pen('サバンナ', capacity: 4, temp: 28)
      house(build_adult(catalog.lion, name: 'A'), savanna)
      house(build_adult(catalog.lion, name: 'B'), savanna)

      expect(occupancy.overcrowded?(savanna)).to be(false)
    end

    it '必要面積の合計が区画の広さを超えると過密になること' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)
      house(build_adult(catalog.african_elephant), savanna)

      expect(occupancy.overcrowded?(savanna)).to be(true)
    end
  end

  describe '収容可否のルール' do
    it '定員に達した区画にはこれ以上収容できないこと' do
      savanna = pen('サバンナ', capacity: 1)
      house(build_adult(catalog.lion, name: '先客'), savanna)

      violation = occupancy.admission_violation(savanna, build_adult(catalog.lion, name: '新入り'))
      expect(violation).to be_a(Zoo::Domain::Errors::CapacityExceeded)
    end

    it '適温域に合わない区画には収容できないこと' do
      tropics = pen('熱帯', temp: 35)

      violation = occupancy.admission_violation(tropics, build_adult(catalog.emperor_penguin))
      expect(violation).to be_a(Zoo::Domain::Errors::ClimateMismatch)
    end

    it '捕食関係にある種は同居できないこと' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)
      house(build_adult(catalog.lion, name: 'ライオン'), savanna)

      violation = occupancy.admission_violation(savanna, build_adult(catalog.african_elephant))
      expect(violation).to be_a(Zoo::Domain::Errors::IncompatibleCohabitation)
    end

    it '死亡した動物は収容できないこと' do
      savanna = pen('サバンナ')
      carcass = build_adult(catalog.lion).tap { |a| a.die(cause: :illness) }

      violation = occupancy.admission_violation(savanna, carcass)
      expect(violation).to be_a(Zoo::Domain::Errors::DeadAnimal)
    end

    it 'ルールに反しなければ収容できること' do
      savanna = pen('サバンナ', capacity: 4, temp: 25)

      expect(occupancy.can_admit?(savanna, build_adult(catalog.lion))).to be(true)
    end
  end
end
