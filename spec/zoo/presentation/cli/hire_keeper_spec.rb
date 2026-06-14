# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::HireKeeper do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it 'NAME と専門綱を渡すと飼育員が保存され、採用メッセージを出すこと' do
      handler.run(%w[田中 mammal])

      expect(container.keepers.all.size).to eq(1)
      expect(output.string).to include('採用しました（飼育員）', '田中')
    end

    it '未知の綱 dragon を渡すと ArgumentError(未知の綱) を上げること' do
      expect { handler.run(%w[田中 dragon]) }.to raise_error(ArgumentError, /未知の綱/)
    end

    it '綱を1つも渡さないと ArgumentError(使い方) を上げること' do
      expect { handler.run(['田中']) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
