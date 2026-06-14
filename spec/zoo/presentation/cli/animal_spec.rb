# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Animal do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  let(:lion) { build_adult(catalog.lion, name: 'レオ').tap { |a| container.animals.save(a) } }

  describe '#run' do
    it 'ANIMAL_ID を渡すと名前・種・体力・状態などの詳細を出力すること' do
      handler.run([lion.id.to_s])

      expect(output.string).to include('レオ（ライオン / 哺乳類', '体力: 100/100', '状態: 生存')
    end

    it "存在しない id='missing' を渡すと Application::Errors::AnimalNotFound を上げること" do
      expect { handler.run(['missing']) }.to raise_error(Zoo::Application::Errors::AnimalNotFound)
    end

    it '引数不足だと ArgumentError(使い方) を上げること' do
      expect { handler.run([]) }.to raise_error(ArgumentError, /使い方/)
    end
  end
end
