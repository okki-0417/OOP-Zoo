# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Treatment do
      let(:vet) { Veterinarian.new(name: '佐藤') }
      let(:animal) { build_adult(SpeciesCatalog.lion) }

      def treat
        described_class.new(veterinarian: vet, animal: animal).perform
      end

      describe '#perform' do
        it '病気の個体を治療すると病気が治ること' do
          animal.fall_ill(IllnessCatalog.pneumonia)
          treat
          expect(animal).not_to be_sick
        end

        it '衰弱した個体を治療すると回復すること' do
          90.times { animal.cry_out }
          treat
          expect(animal.weak?).to be(false)
        end

        it '死亡個体は治療できず DeadAnimal を出すこと' do
          animal.die
          expect { treat }.to raise_error(Errors::DeadAnimal)
        end
      end

      describe '#to_s' do
        it '獣医が動物を治療 の形で表されること' do
          expect(described_class.new(veterinarian: vet, animal: animal).to_s)
            .to eq("佐藤が#{animal.name}を治療")
        end
      end
    end
  end
end
