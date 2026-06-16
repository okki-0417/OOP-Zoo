# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Tui::BreedAnimals do
  shared    = Zoo::Domain::Shared
  husbandry = Zoo::Domain::Husbandry
  catalog   = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:prompt) { instance_double(TTY::Prompt) }
  let(:view) { Zoo::Presentation::Tui::View.new }
  let(:action) { described_class.new(container: container, prompt: prompt, output: output, view: view) }

  let(:pair) { build_pair(catalog.lion) }
  let(:enclosure) do
    husbandry::Enclosure.new(name: 'ライオンの丘', temperature: shared::Temperature.celsius(28), capacity: 4)
                        .tap { |e| container.enclosures.save(e) }
  end

  describe '#call' do
    it '父・母・収容先を選び、名前と性別を入力すると子が誕生すること' do
      sire, dam = pair
      container.animals.save(sire)
      container.animals.save(dam)

      allow(prompt).to receive(:select).and_return(sire.id.to_s, dam.id.to_s, enclosure.id.to_s, 'male')
      allow(prompt).to receive(:ask).and_return('シンバ')

      action.call

      expect(output.string).to include('誕生しました: シンバ')
      expect(container.birth_announcements.announcements.size).to eq(1)
    end
  end
end
