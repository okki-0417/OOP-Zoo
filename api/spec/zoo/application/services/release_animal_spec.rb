# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ReleaseAnimal do
  catalog = Zoo::Domain::SpeciesCatalog

  let!(:enclosure) { create_enclosure }
  let!(:lion) { build_adult(catalog.lion, name: 'レオ').move_to(enclosure).tap(&:save!) }

  def release(animal_id)
    described_class.new(command: Zoo::Application::Commands::ReleaseAnimalCommand.new(animal_id:)).call
  end

  describe '#call' do
    it '収容中の個体を退去させるとエリアの animals から外れ、enclosure が nil になること' do
      release(lion.id)

      expect(enclosure.animals.reload).not_to include(lion)
      expect(lion.reload.enclosure).to be_nil
    end

    it '退去に成功すると result.value がレオになること' do
      expect(release(lion.id).value).to eq(lion)
    end

    it '存在しない animal_id=\'missing\' を渡すと result.error が AnimalNotFound になること' do
      expect(release('missing').error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end

    it 'どのエリアにも収容されていない個体だと ArgumentError になること' do
      loose = build_adult(catalog.lion, name: '野良').tap(&:save!)

      expect { release(loose.id) }
        .to raise_error(ArgumentError, /収容されていません/)
    end
  end
end
