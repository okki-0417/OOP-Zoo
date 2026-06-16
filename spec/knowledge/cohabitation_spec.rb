# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '同居適性' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  policy  = Zoo::Domain::Husbandry::CohabitationPolicy

  describe '同種を同居させるか' do
    context '群れで暮らす種(ライオン)どうしのとき' do
      it '群れを成すので同居できること' do
        expect(policy.compatible?(catalog.lion, catalog.lion)).to be(true)
      end
    end

    context '単独性の種(ホッキョクグマ)どうしのとき' do
      it '縄張りを争うので同居できないこと' do
        expect(policy.compatible?(catalog.polar_bear, catalog.polar_bear)).to be(false)
      end

      it '単独性であることが理由として示されること' do
        reason = policy.incompatibility_reason(catalog.polar_bear, catalog.polar_bear)
        expect(reason).to include('単独性')
      end
    end
  end

  describe '異種を同居させるか' do
    context '一方が捕食性(肉食のライオンと草食のシマウマ)のとき' do
      it '捕食の恐れがあるので同居できないこと' do
        expect(policy.compatible?(catalog.lion, catalog.grevys_zebra)).to be(false)
      end

      it '捕食関係であることが理由として示されること' do
        reason = policy.incompatibility_reason(catalog.lion, catalog.grevys_zebra)
        expect(reason).to include('捕食')
      end

      it '魚食(フンボルトペンギン)も捕食性として扱われ同居できないこと' do
        expect(policy.compatible?(catalog.humboldt_penguin, catalog.red_panda)).to be(false)
      end
    end

    context 'どちらも非捕食で適温域が重なる(草食のシマウマとキリン)とき' do
      it '同居できること' do
        expect(policy.compatible?(catalog.grevys_zebra, catalog.reticulated_giraffe)).to be(true)
      end
    end
  end

  describe '気候の両立' do
    context '適温域が重ならない(熱帯のゾウガメと極地のコウテイペンギン)とき' do
      it '同じエリアの気温で両立できないので同居できないこと' do
        expect(policy.compatible?(catalog.galapagos_tortoise, catalog.emperor_penguin)).to be(false)
      end

      it '適温域が両立しないことが理由として示されること' do
        reason = policy.incompatibility_reason(catalog.galapagos_tortoise, catalog.emperor_penguin)
        expect(reason).to include('適温域')
      end
    end
  end
end
