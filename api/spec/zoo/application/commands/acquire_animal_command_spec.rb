# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Commands::AcquireAnimalCommand do
  let(:input) { { species_code: 'lion', name: 'レオ', sex: 'male' } }
  let(:tools) { { unit_of_work: :uow, animals: :animals, species: :species, zoo: :zoo } }

  describe '.new' do
    it "species_code='lion'・name='レオ'・sex='male' を渡すと各値を読み出せ、max_health=100・age_in_days=0 が既定になること" do
      command = described_class.new(**input)

      expect(command).to have_attributes(species_code: 'lion', name: 'レオ', sex: 'male', max_health: 100, age_in_days: 0)
    end

    it '生成直後は道具(animals/species/zoo/unit_of_work)がすべて nil であること' do
      command = described_class.new(**input)

      expect(command).to have_attributes(animals: nil, species: nil, zoo: nil, unit_of_work: nil)
    end

    %i[species_code name sex].each do |key|
      it "#{key}=nil で生成すると「#{key} は必須です」の ArgumentError になること" do
        expect { described_class.new(**input, key => nil) }
          .to raise_error(ArgumentError, "#{key} は必須です")
      end
    end
  end

  describe '#bind' do
    it 'unit_of_work/animals/species/zoo を渡すと、それらを持つコマンドを返すこと' do
      bound = described_class.new(**input).bind(**tools)

      expect(bound).to have_attributes(unit_of_work: :uow, animals: :animals, species: :species, zoo: :zoo)
      expect(bound).to have_attributes(species_code: 'lion', name: 'レオ', sex: 'male')
    end

    it '使わない道具(enclosures 等)を一緒に渡しても無視されること' do
      bound = described_class.new(**input).bind(**tools, enclosures: :enclosures, housings: :housings)

      expect(bound).not_to respond_to(:enclosures)
      expect(bound.animals).to eq(:animals)
    end

    it 'zoo を渡さないと missing keyword の ArgumentError になること' do
      expect { described_class.new(**input).bind(**tools.except(:zoo)) }
        .to raise_error(ArgumentError, /missing keyword: :zoo/)
    end

    it '新しいインスタンスを返し、元のコマンドの道具は nil のままであること' do
      command = described_class.new(**input)
      bound = command.bind(**tools)

      expect(bound).not_to be(command)
      expect(command.animals).to be_nil
    end
  end
end
