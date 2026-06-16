# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe 'Zoo::Presentation::Tui スタッフ系アクション' do
  taxonomy = Zoo::Domain::Taxonomy
  staff    = Zoo::Domain::Staff

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:view) { Zoo::Presentation::Tui::View.new }

  let(:vet) { staff::Veterinarian.new(name: '山田').tap { |v| container.veterinarians.save(v) } }
  let(:lion) { build_adult(taxonomy::SpeciesCatalog.lion, name: 'レオ').tap { |a| container.animals.save(a) } }

  def run(klass)
    klass.new(container: container, prompt: prompt, output: output, view: view).call
  end

  describe Zoo::Presentation::Tui::TreatAnimal do
    it '獣医と個体を選ぶと治療できること' do
      allow(prompt).to receive(:select).and_return(vet.id.to_s, lion.id.to_s)

      run(described_class)

      expect(output.string).to include('治療しました: レオ')
    end
  end

  describe Zoo::Presentation::Tui::ExamineAnimal do
    it '健康な個体を診ると「診断: 健康」を出すこと' do
      allow(prompt).to receive(:select).and_return(vet.id.to_s, lion.id.to_s)

      run(described_class)

      expect(output.string).to include('診断: 健康')
    end
  end

  describe Zoo::Presentation::Tui::AdmitVisitors do
    it '来園者数を入力すると累計収益を出すこと(2000円×100=¥200,000)' do
      allow(prompt).to receive(:ask).and_return(100)

      run(described_class)

      expect(output.string).to include('累計収益: ¥200,000')
    end
  end
end
