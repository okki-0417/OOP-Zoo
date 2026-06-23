# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Examination do
      let(:vet) { Veterinarian.new(name: '佐藤') }
      let(:animal) { build_adult(SpeciesCatalog.lion) }

      def diagnose
        described_class.new(veterinarian: vet, animal: animal).diagnosis
      end

      describe '#diagnosis' do
        it '異常のない個体は :healthy と診断すること' do
          expect(diagnose).to eq(:healthy)
        end

        it '病気の個体は :sick と診断すること' do
          animal.fall_ill(IllnessCatalog.pneumonia)
          expect(diagnose).to eq(:sick)
        end

        it '衰弱した個体は :injured と診断すること' do
          90.times { animal.cry_out }
          expect(diagnose).to eq(:injured)
        end

        it '死亡個体は :dead と診断すること' do
          animal.die
          expect(diagnose).to eq(:dead)
        end
      end

      describe '#to_s' do
        it '獣医が動物を診察 の形で表されること' do
          expect(described_class.new(veterinarian: vet, animal: animal).to_s)
            .to eq("佐藤が#{animal.name}を診察")
        end
      end
    end
  end
end
