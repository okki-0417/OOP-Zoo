# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '同居適性' do
  catalog = Zoo::Domain::SpeciesCatalog
  errors  = Zoo::Domain::Errors

  # 同居の可否は「ある種の個体を、別種が先住する区画へ収容できるか」という
  # 入園判定として観測される。新入りの適温域に収まる区画を用意し、
  # 気温自体は入園を妨げないようにして同居ルールだけを浮かび上がらせる。
  def admission(newcomer_species, resident_species)
    enclosure = Zoo::Domain::Enclosure.new(
      name: '展示エリア',
      temperature: newcomer_species.habitable_temperature_range.begin,
      capacity: 9
    )
    occupancy = Zoo::Domain::Occupancy.new(enclosure, [build_adult(resident_species, name: '先住')])
    Zoo::Domain::Housing.new(
      animal: build_adult(newcomer_species, name: '新入り'),
      enclosure: enclosure,
      occupancy: occupancy
    )
  end

  describe '同種を同居させるか' do
    context '群れで暮らす種(ライオン)どうしのとき' do
      it '群れを成すので収容できること' do
        expect { admission(catalog.lion, catalog.lion).admission_violation! }.not_to raise_error
      end
    end

    context '単独性の種(ホッキョクグマ)どうしのとき' do
      it '縄張りを争うので収容を拒否され、単独性が理由として示されること' do
        expect { admission(catalog.polar_bear, catalog.polar_bear).admission_violation! }
          .to raise_error(errors::HousingNotAllowed, /単独性/)
      end
    end
  end

  describe '異種を同居させるか' do
    context '一方が捕食性(肉食のライオンと草食のシマウマ)のとき' do
      it '捕食の恐れがあるので収容を拒否され、捕食関係が理由として示されること' do
        expect { admission(catalog.lion, catalog.grevys_zebra).admission_violation! }
          .to raise_error(errors::HousingNotAllowed, /捕食/)
      end

      it '魚食(フンボルトペンギン)も捕食性として扱われ収容を拒否されること' do
        expect { admission(catalog.humboldt_penguin, catalog.red_panda).admission_violation! }
          .to raise_error(errors::HousingNotAllowed)
      end
    end

    context 'どちらも非捕食で適温域が重なる(草食のシマウマとキリン)とき' do
      it '収容できること' do
        expect { admission(catalog.grevys_zebra, catalog.reticulated_giraffe).admission_violation! }
          .not_to raise_error
      end
    end
  end

  describe '気候の両立' do
    context '適温域が重ならない(熱帯のゾウガメと極地のコウテイペンギン)とき' do
      it '同じ気温で両立できないので収容を拒否され、適温域の不一致が理由として示されること' do
        expect { admission(catalog.galapagos_tortoise, catalog.emperor_penguin).admission_violation! }
          .to raise_error(errors::HousingNotAllowed, /適温域/)
      end
    end
  end
end
