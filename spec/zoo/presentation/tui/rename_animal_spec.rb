# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Tui::RenameAnimal do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:view) { Zoo::Presentation::Tui::View.new }
  let(:action) { described_class.new(container: container, prompt: prompt, output: output, view: view) }

  let(:lion) { build_adult(catalog.lion, name: 'レオ').tap { |a| container.animals.save(a) } }

  describe '#call' do
    it '個体を選び新しい名前を入力すると改名されること' do
      allow(prompt).to receive(:select).and_return(lion.id.to_s)
      allow(prompt).to receive(:ask).and_return('シンバ')

      action.call

      expect(container.animals.find(lion.id).name.to_s).to eq('シンバ')
      expect(output.string).to include('改名しました: シンバ')
    end
  end
end
