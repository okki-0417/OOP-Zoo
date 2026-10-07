# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::Commands::AcquireAnimalCommand do
  let(:input) { { species_code: 'lion', name: 'レオ', sex: 'male' } }

  describe '.new' do
    it "species_code='lion'・name='レオ'・sex='male' を渡すと各値を読み出せ、max_health=100・age_in_days=0 が既定になること" do
      command = described_class.new(**input)

      expect(command).to have_attributes(species_code: 'lion', name: 'レオ', sex: 'male', max_health: 100, age_in_days: 0)
    end

    %i[species_code name sex].each do |key|
      it "#{key}=nil で生成すると「#{key} は必須です」の ArgumentError になること" do
        expect { described_class.new(**input, key => nil) }
          .to raise_error(ArgumentError, "#{key} は必須です")
      end
    end
  end
end
