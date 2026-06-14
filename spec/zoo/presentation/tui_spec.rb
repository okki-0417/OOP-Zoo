# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Tui do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:tui) { described_class.new(container: container, prompt: prompt, output: output) }

  describe '#run' do
    it 'メニューで「終了」を選ぶとループを抜けること' do
      allow(prompt).to receive(:select).and_return('終了')

      expect { tui.run }.not_to raise_error
    end
  end

  describe '#dispatch' do
    it 'アクションが上げたドメイン例外をメッセージに翻訳して落ちないこと' do
      failing = Class.new(Zoo::Presentation::Tui::Action) do
        def call
          raise Zoo::Domain::Errors::CapacityExceeded, 'エリアは定員に達しています'
        end
      end

      tui.dispatch(failing)

      expect(output.string).to include('エリアは定員に達しています')
    end
  end
end
