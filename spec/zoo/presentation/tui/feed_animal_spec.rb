# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Tui::FeedAnimal do
  taxonomy = Zoo::Domain::Taxonomy
  staff    = Zoo::Domain::Staff

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:view) { Zoo::Presentation::Tui::View.new }
  let(:action) { described_class.new(container: container, prompt: prompt, output: output, view: view) }

  let(:keeper) do
    staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal]).tap { |k| container.keepers.save(k) }
  end
  let(:lion) { build_adult(taxonomy::SpeciesCatalog.lion, name: 'レオ').tap { |a| container.animals.save(a) } }

  describe '#call' do
    it '選択した飼育員・個体・餌で給餌すること' do
      keeper
      lion.get_hungrier(40)

      allow(prompt).to receive(:select).and_return(keeper.id.to_s, lion.id.to_s, :horse_meat)

      action.call

      expect(output.string).to include('給餌しました: レオ')
    end

    it '飼育員がいなければ「飼育員がいません」を出して中断すること' do
      lion
      allow(prompt).to receive(:select)

      action.call

      expect(output.string).to include('飼育員がいません')
    end
  end
end
