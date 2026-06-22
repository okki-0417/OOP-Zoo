# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '飼育員の担当割り当てに対するルール(専門一致)' do
  taxonomy = Zoo::Domain
  catalog  = Zoo::Domain::SpeciesCatalog

  def pen(name = '区画', capacity: 4, temp: 25)
    Zoo::Domain::Enclosure.new(
      name: name, temperature: Zoo::Domain::Shared::Temperature.celsius(temp), capacity: capacity
    )
  end

  def assign!(keeper, enclosure, occupants = [])
    Zoo::Domain::EnclosureAssignment.new(keeper: keeper, enclosure: enclosure, occupants: occupants)
                                    .assignment_violation!
  end

  let(:mammal_keeper) { Zoo::Domain::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]) }

  describe '専門の綱と担当エリアの一致' do
    it '専門の綱の動物だけがいるエリアには担当割り当てできること' do
      savanna = pen('サバンナ', temp: 28)
      residents = [build_adult(catalog.lion), build_adult(catalog.grevys_zebra)]

      expect { assign!(mammal_keeper, savanna, residents) }.not_to raise_error
    end

    it '専門外の綱の動物がいるエリアには担当割り当てできないこと' do
      pool = pen('ペンギンプール', temp: 0)

      expect { assign!(mammal_keeper, pool, [build_adult(catalog.emperor_penguin)]) }
        .to raise_error(Zoo::Domain::Errors::EnclosureAssignmentNotAllowed, /鳥類/)
    end

    it '専門の綱と専門外の綱が混在するエリアには担当割り当てできないこと' do
      mixed = pen('混合展示', temp: 22)
      residents = [build_adult(catalog.lion), build_adult(catalog.emperor_penguin)]

      expect { assign!(mammal_keeper, mixed, residents) }
        .to raise_error(Zoo::Domain::Errors::EnclosureAssignmentNotAllowed)
    end

    it '複数の専門を持つ飼育員は担当できる綱の範囲が広がること' do
      generalist = Zoo::Domain::Keeper.new(
        name: '万能', specialties: [taxonomy::TaxonClass.mammal, taxonomy::TaxonClass.bird]
      )
      mixed = pen('混合展示', temp: 22)
      residents = [build_adult(catalog.lion), build_adult(catalog.emperor_penguin)]

      expect { assign!(generalist, mixed, residents) }.not_to raise_error
    end

    it '動物のいない空のエリアにはどの飼育員でも担当割り当てできること' do
      empty = pen('準備中', temp: 25)

      expect { assign!(mammal_keeper, empty) }.not_to raise_error
    end
  end
end
