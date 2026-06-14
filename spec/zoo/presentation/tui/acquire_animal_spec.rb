# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Tui::AcquireAnimal do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:view) { Zoo::Presentation::Tui::View.new }
  let(:action) { described_class.new(container: container, prompt: prompt, output: output, view: view) }

  describe '#call' do
    it '選択した種・性別と入力名で個体を受け入れ、Container に保存すること' do
      allow(prompt).to receive(:select).and_return(:lion, 'male') # 種 → 性別
      allow(prompt).to receive(:ask).and_return('レオ')

      action.call

      expect(container.animals.all.size).to eq(1)
      expect(output.string).to include('受け入れました: レオ')
    end
  end
end
