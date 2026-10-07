# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '同居適性' do
  # 同居の可否は「ある種の個体を、別種が先住する区画へ収容できるか」という
  # 入園判定として観測される。新入りの適温域に収まる区画を用意し、
  # 気温自体は入園を妨げないようにして同居ルールだけを浮かび上がらせる。
  def admission(newcomer_species, resident_species)
    enclosure = Enclosure.new(
      name: '展示エリア', temperature: newcomer_species.habitable_temperature_range.begin, capacity: 9
    )
    occupancy = build_occupancy(enclosure, [build_adult(resident_species, name: '先住')])
    Housing.new(
      animal: build_adult(newcomer_species, name: '新入り'),
      enclosure: enclosure,
      occupancy: occupancy
    )
  end

  describe '同種を同居させるか' do
    context '群れで暮らす種(ライオン)どうしのとき' do
      it '群れを成すので収容できること' do
        expect { admission(SpeciesCatalog.lion, SpeciesCatalog.lion).admission_violation! }.not_to raise_error
      end
    end

    context '単独性の種(ホッキョクグマ)どうしのとき' do
      it '縄張りを争うので収容を拒否され、単独性が理由として示されること' do
        expect { admission(SpeciesCatalog.polar_bear, SpeciesCatalog.polar_bear).admission_violation! }
          .to raise_error(Errors::HousingNotAllowed, /単独性/)
      end
    end
  end

  describe '異種を同居させるか' do
    context '一方が捕食性(肉食のライオンと草食のシマウマ)のとき' do
      it '捕食の恐れがあるので収容を拒否され、捕食関係が理由として示されること' do
        expect { admission(SpeciesCatalog.lion, SpeciesCatalog.grevys_zebra).admission_violation! }
          .to raise_error(Errors::HousingNotAllowed, /捕食/)
      end

      it '魚食(フンボルトペンギン)も捕食性として扱われ収容を拒否されること' do
        expect { admission(SpeciesCatalog.humboldt_penguin, SpeciesCatalog.red_panda).admission_violation! }
          .to raise_error(Errors::HousingNotAllowed)
      end
    end

    context 'どちらも非捕食で適温域が重なる(草食のシマウマとキリン)とき' do
      it '収容できること' do
        expect { admission(SpeciesCatalog.grevys_zebra, SpeciesCatalog.reticulated_giraffe).admission_violation! }
          .not_to raise_error
      end
    end
  end

  describe '気候の両立' do
    context '適温域が重ならない(熱帯のゾウガメと極地のコウテイペンギン)とき' do
      it '同じ気温で両立できないので収容を拒否され、適温域の不一致が理由として示されること' do
        expect { admission(SpeciesCatalog.galapagos_tortoise, SpeciesCatalog.emperor_penguin).admission_violation! }
          .to raise_error(Errors::HousingNotAllowed, /適温域/)
      end
    end
  end
end
