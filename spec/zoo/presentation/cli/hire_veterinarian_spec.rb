# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::HireVeterinarian do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it 'NAME を渡すと獣医が保存され、採用メッセージを出すこと' do
      handler.run(['山田'])

      expect(container.veterinarians.all.size).to eq(1)
      expect(output.string).to include('採用しました（獣医）', '山田')
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run([]) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
