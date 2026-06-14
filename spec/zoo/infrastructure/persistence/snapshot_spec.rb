# frozen_string_literal: true

require 'spec_helper'
require 'tmpdir'

RSpec.describe Zoo::Infrastructure::Persistence::Snapshot do
  it 'dump した状態を load で同値に復元できること' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'sub', 'state.bin')
      state = { a: 1, list: %w[x y] }

      described_class.dump(state, path)

      expect(described_class.exist?(path)).to be(true)
      expect(described_class.load(path)).to eq(state)
    end
  end

  it '1回の dump 内で共有された参照は復元後も同一であること' do
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'state.bin')
      shared = +'shared'
      described_class.dump({ x: shared, y: shared }, path)

      loaded = described_class.load(path)

      expect(loaded[:x]).to equal(loaded[:y]) # 同一オブジェクト
    end
  end
end
