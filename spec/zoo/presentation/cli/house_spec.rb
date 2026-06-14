# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::House do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  let(:enclosure) do
    Zoo::Domain::Husbandry::Enclosure.new(
      name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4
    ).tap { |e| container.enclosures.save(e) }
  end
  let(:lion) { build_adult(Zoo::Domain::Taxonomy::SpeciesCatalog.lion, name: 'レオ').tap { |a| container.animals.save(a) } }

  describe '#run' do
    it 'エリアと個体の id を渡すと収容され、確認メッセージを出すこと' do
      handler.run([enclosure.id.to_s, lion.id.to_s])

      expect(container.enclosures.find(enclosure.id).occupants).to include(lion)
      expect(output.string).to include('収容しました')
    end

    it "存在しない animal_id='missing' は Application::Errors::AnimalNotFound を上げること" do
      expect { handler.run([enclosure.id.to_s, 'missing']) }
        .to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run(['only-one']) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
