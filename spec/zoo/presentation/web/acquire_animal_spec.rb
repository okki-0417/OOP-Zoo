# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Presentation::Web::AcquireAnimal do
  let(:container) { Zoo::Composition::Container.new }
  let(:action) { described_class.new(container: container) }

  describe '#call' do
    it 'params から個体を作り [201, 動物プロフィール] を返し、Container に保存すること' do
      code, data = action.call('species' => 'lion', 'name' => 'レオ', 'sex' => 'male')

      expect(code).to eq(201)
      expect(data).to include(name: 'レオ', species: 'ライオン', health: 100, alive: true)
      expect(container.animals.all.size).to eq(1)
    end

    it '未知の種を渡すと ArgumentError を上げること(翻訳はルーターの責務)' do
      expect { action.call('species' => 'dragon', 'name' => 'X', 'sex' => 'male') }
        .to raise_error(ArgumentError, /未知の種/)
    end
  end
end
