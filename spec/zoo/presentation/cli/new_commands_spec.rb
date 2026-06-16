# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe 'Zoo::Presentation::Cli 追加コマンド' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  events  = Zoo::Domain::Events

  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }

  def run(klass, args)
    klass.new(container: container, output: output).run(args)
  end

  describe Zoo::Presentation::Cli::Rename do
    it 'ANIMAL_ID NEW_NAME で改名すること' do
      lion = build_adult(catalog.lion, name: 'レオ').tap { |a| container.animals.save(a) }

      run(described_class, [lion.id.to_s, 'シンバ'])

      expect(output.string).to include('改名しました: シンバ')
    end
  end

  describe Zoo::Presentation::Cli::Deceased do
    it '死亡記録があれば名前と死因を出すこと' do
      lion = build_adult(catalog.lion, name: 'レオ')
      container.event_store.append(events::AnimalDied.new(animal: lion, cause: :old_age))

      run(described_class, [])

      expect(output.string).to include('レオ', '老衰')
    end

    it '死亡が無ければ「死亡記録はありません」を出すこと' do
      run(described_class, [])

      expect(output.string).to include('死亡記録はありません')
    end
  end
end
