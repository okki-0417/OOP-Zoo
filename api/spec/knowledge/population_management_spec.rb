# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '個体群管理(交配推奨)' do
  describe '遺伝的多様性を保つ推奨' do
    context '血縁の異なる候補が複数いるとき' do
      it '平均血縁度(mean kinship)が最も低くなるペアを推奨すること'
    end

    context '組める相手が近親(親子)しかいないとき' do
      it '近親は推奨せず、推奨ペアが無いこと'
    end

    context '繁殖可能な異性がいないとき' do
      it '推奨ペアが無いこと'
    end
  end
end
