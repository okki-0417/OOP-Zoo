# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal::Sex do
  it 'オス・メスを生成できること' do
    expect(described_class.male).to be_male
    expect(described_class.female).to be_female
  end

  it '異性かどうかを判定できること' do
    expect(described_class.male.opposite?(described_class.female)).to be(true)
    expect(described_class.male.opposite?(described_class.male)).to be(false)
  end

  it '未知の性別はエラーになること' do
    expect { described_class.new(:unknown) }.to raise_error(ArgumentError)
  end
end
