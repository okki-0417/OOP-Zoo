# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Taxonomy::Weight do
  it 'kg/tから生成し相互変換できること' do
    expect(described_class.from_kilograms(2).grams).to eq(2000)
    expect(described_class.from_tons(3).kilograms).to eq(3000)
  end

  it '大小比較ができること' do
    expect(described_class.from_kilograms(2)).to be > described_class.from_grams(500)
  end

  it '加算できること' do
    expect((described_class.from_grams(300) + described_class.from_grams(200)).grams).to eq(500)
  end

  it '0以下はエラーになること' do
    expect { described_class.from_grams(0) }.to raise_error(ArgumentError)
  end

  it '人間に読みやすい単位で表示すること' do
    expect(described_class.from_tons(3).to_s).to eq('3.00t')
    expect(described_class.from_kilograms(2).to_s).to eq('2.0kg')
    expect(described_class.from_grams(50).to_s).to eq('50g')
  end
end
