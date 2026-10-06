# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '収入源' do
  describe '会員・年間パス' do
    it '会員(年間パス)は再来園を生み、集客の床を作ること'
    it '会員収入は通常入園料より単価は低いが、収入の季節変動を平準化すること'
  end

  describe '園内消費(物販・飲食・駐車場)' do
    it '集客数に応じた二次消費(物販・飲食)の収入が生まれること'
    it '見応え・評判の高い園ほど、来園者あたりの二次消費(客単価)が増えること'
  end

  describe '寄付・遺贈' do
    it '評判が高いほど寄付が集まりやすいこと'
  end

  describe '助成金・補助金' do
    it '絶滅危惧種の繁殖など保全活動は助成金の対象になること'
  end

  describe 'スポンサー・動物オーナー制度' do
    it 'カリスマ性の高い種・個体(＝見応えの源)にはスポンサー収入がつくこと'
  end

  describe '動物の売却・譲渡' do
    it '余剰個体を売却して資金化できること'
    it '売値は体格・希少度・健康状態で決まること'
    it '絶滅危惧種(CITES制限)は売却できないこと'
  end

  describe '特別イベント' do
    it '季節イベント(ナイトズー等)は一時的に見応え(話題)を高め、集客と収入を押し上げること'
  end
end
