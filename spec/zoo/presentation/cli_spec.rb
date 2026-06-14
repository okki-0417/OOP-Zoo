# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:cli) { described_class.new(container: container, output: output) }

  describe '#run' do
    it '既知のコマンドを対応ハンドラに配送し、0 を返すこと' do
      status = cli.run(['population'])

      expect(output.string).to include('在園数:')
      expect(status).to eq(0)
    end

    it "未知のコマンド 'fly' は『未知のコマンド』を出力して1を返すこと" do
      status = cli.run(['fly'])

      expect(output.string).to include('未知のコマンド: fly')
      expect(status).to eq(1)
    end

    it 'ハンドラが上げた例外をユーザ向けメッセージに翻訳して1を返すこと' do
      status = cli.run(['acquire']) # 引数不足で ArgumentError を誘発

      expect(output.string).to start_with('エラー: ')
      expect(status).to eq(1)
    end
  end
end
