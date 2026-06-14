# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::BuildEnclosure do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it 'NAME CELSIUS CAPACITY を渡すとエリアが保存され、作成メッセージを出すこと' do
      handler.run(['ライオンの丘', '28', '4'])

      expect(container.enclosures.all.size).to eq(1)
      expect(output.string).to include('エリアを作成しました', 'ライオンの丘')
    end

    it '数値でない CELSIUS を渡すと ArgumentError を上げること' do
      expect { handler.run(['ライオンの丘', 'hot', '4']) }.to raise_error(ArgumentError)
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run(['ライオンの丘']) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
