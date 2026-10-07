# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Housing do
  let(:lion) { build_adult(SpeciesCatalog.lion, name: 'レオ') }
  let(:savanna) do
    Enclosure.new(name: 'サバンナ', temperature: Temperature.celsius(28), capacity: 4)
  end

  let(:empty) { build_occupancy(savanna, []) }

  describe '.new' do
    it 'animal: レオ・enclosure: サバンナを渡すと #animal / #enclosure で読み出せること' do
      housing = described_class.new(animal: lion, enclosure: savanna, occupancy: empty)
      expect(housing.animal).to eq(lion)
      expect(housing.enclosure).to eq(savanna)
    end
  end

  it 'イミュータブルであること' do
    expect(described_class.new(animal: lion, enclosure: savanna, occupancy: empty)).to be_frozen
  end

  it '#to_s が収容を表すこと' do
    expect(described_class.new(animal: lion, enclosure: savanna, occupancy: empty).to_s).to eq('レオを収容')
  end

  describe '#perform' do
    it '違反がなければレオの enclosure がサバンナになり、保存されること' do
      described_class.new(animal: lion, enclosure: savanna, occupancy: empty).perform

      expect(lion.reload.enclosure).to eq(savanna)
    end

    it '違反があれば HousingNotAllowed を投げ、レオは保存されず enclosure も nil のままであること' do
      lion.die

      expect { described_class.new(animal: lion, enclosure: savanna, occupancy: empty).perform }
        .to raise_error(Errors::HousingNotAllowed)
      expect(lion).to be_new_record
      expect(lion.enclosure).to be_nil
    end

    it 'occupancy を省略すると保存済みの住人から占有を組み立て、定員1のエリアに先住がいれば HousingNotAllowed(定員) になること' do
      hut = Enclosure.create!(name: '小屋', temperature: Temperature.celsius(28), capacity: 1)
      build_adult(SpeciesCatalog.lion, name: '先住').move_to(hut).save!

      expect { described_class.new(animal: lion, enclosure: hut).perform }
        .to raise_error(Errors::HousingNotAllowed, /定員/)
    end
  end

  describe '#admission_violation!' do
    let(:zebra) { build_adult(SpeciesCatalog.grevys_zebra) }

    def candidate(animal, enclosure, occupants = [])
      occupancy = build_occupancy(enclosure, occupants)
      described_class.new(animal: animal, enclosure: enclosure, occupancy: occupancy)
    end

    it '違反がなければ例外を投げないこと' do
      expect { candidate(lion, savanna).admission_violation! }.not_to raise_error
    end

    it '死亡個体は HousingNotAllowed(死亡) であること' do
      dead = build_adult(SpeciesCatalog.lion).tap(&:die)
      expect { candidate(dead, savanna).admission_violation! }
        .to raise_error(Errors::HousingNotAllowed, /死亡/)
    end

    it '満員だと HousingNotAllowed(定員) であること' do
      full = Enclosure.new(name: '小屋', temperature: Temperature.celsius(28), capacity: 1)
      expect { candidate(lion, full, [build_adult(SpeciesCatalog.lion, name: '先住')]).admission_violation! }
        .to raise_error(Errors::HousingNotAllowed, /定員/)
    end

    it '適温に合わない個体は HousingNotAllowed(適応) であること' do
      cold = Enclosure.new(name: '極地', temperature: Temperature.celsius(-10), capacity: 4)
      expect { candidate(zebra, cold).admission_violation! }
        .to raise_error(Errors::HousingNotAllowed, /適応/)
    end

    it '捕食関係の異種との同居は HousingNotAllowed(捕食) であること' do
      expect { candidate(lion, savanna, [zebra]).admission_violation! }
        .to raise_error(Errors::HousingNotAllowed, /捕食/)
    end

    it '単独性の同種との同居は HousingNotAllowed(単独性) であること' do
      cold = Enclosure.new(name: '極地', temperature: Temperature.celsius(-10), capacity: 4)
      bear = build_adult(SpeciesCatalog.polar_bear, name: '白')
      expect { candidate(bear, cold, [build_adult(SpeciesCatalog.polar_bear, name: '先住')]).admission_violation! }
        .to raise_error(Errors::HousingNotAllowed, /単独性/)
    end

    it '適温域が両立しない種との同居は HousingNotAllowed(適温域) であること' do
      tortoise = build_adult(SpeciesCatalog.galapagos_tortoise, name: 'カメ')
      penguin = build_adult(SpeciesCatalog.emperor_penguin, name: '先住')
      expect { candidate(tortoise, savanna, [penguin]).admission_violation! }
        .to raise_error(Errors::HousingNotAllowed, /適温域/)
    end

    it '複数の違反を一度にまとめて報告すること' do
      full = Enclosure.new(name: '小屋', temperature: Temperature.celsius(28), capacity: 1)
      dead = build_adult(SpeciesCatalog.lion).tap(&:die)
      expect { candidate(dead, full, [build_adult(SpeciesCatalog.lion, name: '先住')]).admission_violation! }
        .to raise_error(Errors::HousingNotAllowed, /死亡.*定員/)
    end
  end
end
