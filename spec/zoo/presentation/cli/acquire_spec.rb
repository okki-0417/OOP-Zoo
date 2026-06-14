# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Acquire do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it '種・名前・性別を渡すと個体が animals に保存され、受け入れメッセージを出すこと' do
      handler.run(%w[lion レオ male])

      expect(container.animals.all.size).to eq(1)
      expect(output.string).to include('受け入れました', 'レオ')
    end

    it "未知の種 'dragon' を渡すと ArgumentError(未知の種) を上げること" do
      expect { handler.run(%w[dragon X male]) }.to raise_error(ArgumentError, /未知の種/)
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run(['lion']) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
