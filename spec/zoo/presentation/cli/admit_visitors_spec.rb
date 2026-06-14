# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::AdmitVisitors do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it 'COUNT を渡すと来園者を受け入れ、累計収益を表示すること(入園料2000円×100=¥200,000)' do
      handler.run(['100'])

      expect(output.string).to include('来園者を受け入れました', '¥200,000')
    end

    it '数値でない COUNT を渡すと ArgumentError を上げること' do
      expect { handler.run(['たくさん']) }.to raise_error(ArgumentError)
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run([]) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
