# frozen_string_literal: true

require 'spec_helper'

# 外的ショックの知識（バックログ）。
#
# 内生圧力(a/b)の上に載せる"試練"の層。備え(準備金・収入や種の多様化)を怠った園を
# 選択的に苦しめる。先に内生の緊張があって初めて意味を持つので、実装順は後段。
# 本文のない `it` は未設計のバックログ(pending)。
RSpec.describe '外的ショック' do
  describe 'スキャンダル' do
    it '動物福祉スキャンダルは評判を暴落させ、集客を落とすこと'
  end

  describe '不況・パンデミック' do
    it '収入が落ちても飼育費(固定費)は止まらず、収支を強く圧迫すること'
    it '準備金のある園はショックを生き延びやすいこと'
  end

  describe '規制・罰金' do
    it '福祉基準違反は罰金の対象になること'
  end

  describe '疫病の発生' do
    it '疫病の発生は獣医費と休園による減収を招くこと'
  end
end
