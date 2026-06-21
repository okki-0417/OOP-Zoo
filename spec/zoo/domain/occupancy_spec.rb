# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Occupancy do
      let(:lion) { SpeciesCatalog.lion }
      let(:zebra) { SpeciesCatalog.grevys_zebra }
      let(:giraffe) { SpeciesCatalog.reticulated_giraffe }

      def pen(name = '区画', capacity: 4, temp: 28)
        Enclosure.new(name: name, temperature: Shared::Temperature.celsius(temp), capacity: capacity)
      end

      describe '#occupants_of' do
        it '収容イベントのある区画の生存個体を返すこと' do
          savanna = pen
          z = build_adult(zebra)
          occupancy = described_class.new([housed(z, savanna)])
          expect(occupancy.occupants_of(savanna)).to contain_exactly(z)
        end

        it '入居を閉じる解放イベントがあると収容個体から外れること' do
          savanna = pen
          z = build_adult(zebra)
          stay = housed(z, savanna)
          occupancy = described_class.new([stay, released(stay)])
          expect(occupancy.occupants_of(savanna)).to be_empty
        end

        it '退去して別区画へ入居し直すと、新しい区画にのみ属すること(転居)' do
          a = pen('A')
          b = pen('B')
          z = build_adult(zebra)
          stay = housed(z, a)
          occupancy = described_class.new([stay, released(stay), housed(z, b)])
          expect(occupancy.occupants_of(a)).to be_empty
          expect(occupancy.occupants_of(b)).to contain_exactly(z)
        end

        it '死亡個体は除外されること' do
          savanna = pen
          z = build_adult(zebra).tap { |a| a.die(cause: :illness) }
          occupancy = described_class.new([housed(z, savanna)])
          expect(occupancy.occupants_of(savanna)).to be_empty
        end
      end

      describe '#all_occupants' do
        it 'どこかに収容されている生存個体をすべて返すこと' do
          a = pen('A')
          b = pen('B')
          x = build_adult(zebra, name: 'x')
          y = build_adult(zebra, name: 'y')
          occupancy = described_class.new([housed(x, a), housed(y, b)])
          expect(occupancy.all_occupants).to contain_exactly(x, y)
        end
      end

      describe '#enclosure_id_of / #houses?' do
        it '収容中の個体は区画 id を返し houses? が真であること' do
          savanna = pen
          z = build_adult(zebra)
          occupancy = described_class.new([housed(z, savanna)])
          expect(occupancy.enclosure_id_of(z)).to eq(savanna.id)
          expect(occupancy.houses?(savanna, z)).to be(true)
        end

        it '解放後は区画 id が nil になること' do
          savanna = pen
          z = build_adult(zebra)
          stay = housed(z, savanna)
          occupancy = described_class.new([stay, released(stay)])
          expect(occupancy.enclosure_id_of(z)).to be_nil
        end

        it '#current_housing_of は現在の入居イベントを返し、解放後は nil になること' do
          savanna = pen
          z = build_adult(zebra)
          stay = housed(z, savanna)
          expect(described_class.new([stay]).current_housing_of(z)).to eq(stay)
          expect(described_class.new([stay, released(stay)]).current_housing_of(z)).to be_nil
        end
      end

      describe '収容数' do
        it 'population_of / vacancies_in / full? / empty? が収容数に追従すること' do
          savanna = pen(capacity: 2)
          occupancy = described_class.new([housed(build_adult(zebra, name: 'a'), savanna)])
          expect(occupancy.population_of(savanna)).to eq(1)
          expect(occupancy.vacancies_in(savanna)).to eq(1)
          expect(occupancy.full?(savanna)).to be(false)
          expect(occupancy.empty?(savanna)).to be(false)
          expect(occupancy.empty?(pen('別'))).to be(true)
        end
      end

      describe '必要面積と過密' do
        it '収容個体の必要面積を合計すること' do
          savanna = pen
          occupancy = described_class.new([housed(build_adult(zebra, name: 'z1'), savanna),
                                           housed(build_adult(zebra, name: 'z2'), savanna)])
          expect(occupancy.required_area_of(savanna)).to eq(200.0)
        end

        it '空のエリアは過密でないこと' do
          expect(described_class.new([]).overcrowded?(pen(capacity: 2))).to be(false)
        end

        it '必要面積が広さを超えると過密であること' do
          small = pen(capacity: 1)
          occupancy = described_class.new([housed(build_adult(giraffe), small)])
          expect(occupancy.overcrowded?(small)).to be(true)
        end
      end

      describe '#species_present_in' do
        it '収容個体の種を重複なく返すこと' do
          savanna = pen
          occupancy = described_class.new([housed(build_adult(zebra, name: 'z'), savanna),
                                           housed(build_adult(giraffe, name: 'g'), savanna)])
          expect(occupancy.species_present_in(savanna).size).to eq(2)
        end
      end

      describe '#subordinate_male?' do
        let(:pride) { pen('丘', capacity: 6) }

        it '成熟オスが複数いると、年長でない方が序列下位であること' do
          senior = build_animal(lion, name: '長老', sex: Animal::Sex.male, age_in_days: 4000)
          junior = build_adult(lion, name: '若', sex: Animal::Sex.male)
          occupancy = described_class.new([housed(senior, pride), housed(junior, pride)])
          expect(occupancy.subordinate_male?(pride, junior)).to be(true)
          expect(occupancy.subordinate_male?(pride, senior)).to be(false)
        end

        it 'オス1頭・メス・未成熟は序列下位でないこと' do
          male = build_adult(lion, sex: Animal::Sex.male)
          female = build_adult(lion, sex: Animal::Sex.female)
          cub = build_animal(lion, name: '仔', sex: Animal::Sex.male, age_in_days: 0)
          occupancy = described_class.new([housed(male, pride), housed(female, pride), housed(cub, pride)])
          expect(occupancy.subordinate_male?(pride, male)).to be(false)
          expect(occupancy.subordinate_male?(pride, female)).to be(false)
          expect(occupancy.subordinate_male?(pride, cub)).to be(false)
        end
      end

      describe '#injury_for' do
        it '序列下位でなければ外傷は0であること' do
          savanna = pen
          z = build_adult(zebra)
          expect(described_class.new([housed(z, savanna)]).injury_for(savanna, z)).to eq(0)
        end
      end
    end
  end
end
