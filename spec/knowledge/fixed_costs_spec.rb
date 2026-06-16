# frozen_string_literal: true

require 'spec_helper'

# 固定費と休園の知識。運営費(飼料費・維持費・人件費)は集客=収入に依存せず、
# 在園頭数・職員・エリアで決まる。ゆえに集客のない休園日でもコストは止まらず、
# 収入が落ちた日ほど収支を圧迫する(固定費の非対称＝「収支＝命」の核)。
#
# 用語（経済ドメイン共通。ブレたらここに合わせる）:
#   集客 = f(魅力, 評判, 料金) … その日の来園者数(フロー)
#   評判 … 運営の質・信用(ストック)。福祉/死亡/スキャンダル/保全/清潔/過密で増減、放置で漸減
#   魅力 … 展示の引き「何が見られるか」。種カリスマ/話題(buzz=幼獣/新展示/イベント)
#   料金 … 入園料(需要レバー、弾力性)
RSpec.describe '固定費と休園' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog

  def savanna
    Zoo::Domain::Husbandry::Enclosure.new(
      name: 'サバンナ', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
    )
  end

  describe '固定費は収入に依存しない' do
    it '在園個体がいれば、来園者のいない休園日でも運営費が発生すること' do
      daily = Zoo::Domain::Operations::OperatingCost.daily(
        enclosures: [savanna], staff: 1, species: [catalog.lion]
      )
      expect(daily.yen).to be > 0
    end

    it '運営費は来園者数ではなく在園頭数で増えること(飼料費)' do
      one = Zoo::Domain::Operations::OperatingCost.daily(
        enclosures: [savanna], staff: 1, species: [catalog.lion]
      )
      two = Zoo::Domain::Operations::OperatingCost.daily(
        enclosures: [savanna], staff: 1, species: [catalog.lion, catalog.african_elephant]
      )
      expect(two.yen).to be > one.yen
    end

    it '在園個体がいなくても、エリアと職員の維持費は発生すること' do
      daily = Zoo::Domain::Operations::OperatingCost.daily(
        enclosures: [savanna], staff: 1, species: []
      )
      expect(daily.yen).to be > 0
    end
  end
end
