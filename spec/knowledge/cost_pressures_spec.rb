# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '継続コストと拡大投資' do
  describe '収容力の拡張(投資)' do
    it '集客の収容力は投資で拡張できること'
    it '収容力を超える需要(集客)は取りこぼされること'
  end

  describe '展示のリニューアル(投資)' do
    it '展示は古びると魅力が落ち、リニューアル投資で回復すること'
  end

  describe '獣医費(継続)' do
    it '高齢・病気の個体ほど獣医費が継続的にかさむこと'
  end

  describe '施設の維持・減価(継続)' do
    it '維持を怠ると施設が劣化し、後の修繕費が大きくなること'
  end

  describe '福祉維持費(継続)' do

    it 'エンリッチメント等の福祉維持費を削ると、個体の福祉(ストレス)が悪化すること'
  end

  describe '人件費' do
    it '職員給与は飼育負荷(頭数・専門)に応じて増えること(現状は定額)'
  end
end
