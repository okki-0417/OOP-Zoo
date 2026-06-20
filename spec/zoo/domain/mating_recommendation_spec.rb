# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe MatingRecommendation do
      SpeciesCatalog.lion

      def founder(name, sex)
        Animal.new(species: SpeciesCatalog.lion, name: name, sex: sex, max_health: 100, age_in_days: 3000)
      end

      describe '.candidate_pairs' do
        it '同種・異性・繁殖可能な組をすべて挙げること' do
          m  = founder('M', Animal::Sex.male)
          f1 = founder('F1', Animal::Sex.female)
          f2 = founder('F2', Animal::Sex.female)

          pairs = described_class.candidate_pairs([m, f1, f2])
          expect(pairs).to contain_exactly([m, f1], [m, f2])
        end

        it '同性しかいなければ空であること' do
          expect(described_class.candidate_pairs([founder('M1', Animal::Sex.male), founder('M2', Animal::Sex.male)]))
            .to eq([])
        end
      end

      describe '.recommend' do
        it '空の集団では nil を返すこと' do
          expect(described_class.recommend([], [])).to be_nil
        end

        it '組める相手が一組だけならそのペアを返すこと' do
          m = founder('M', Animal::Sex.male)
          f = founder('F', Animal::Sex.female)
          expect(described_class.recommend([m, f], [])).to eq([m, f])
        end
      end
    end
  end
end
