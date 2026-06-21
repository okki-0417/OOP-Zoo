# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe EnclosureDay do
      let(:zebra) { SpeciesCatalog.grevys_zebra }
      let(:savanna) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(30), capacity: 4)
      end

      def run(enclosure, occupants, season: Season.spring)
        described_class.new(enclosure, occupants, season: season).run
      end

      it '収容個体が歳をとり、エリアが汚れること' do
        z = build_adult(zebra)
        expect { run(savanna, [z]) }.to change { savanna.cleanliness.level }.by(-1)
        expect(z.age_in_days).to eq(build_adult(zebra).age_in_days + 1)
      end

      it '死亡した個体を返すこと' do
        old_zebra = build_animal(zebra, age_in_days: 365 * 20)
        dead = run(savanna, [old_zebra])
        expect(dead).to include(old_zebra)
        expect(old_zebra).to be_dead
      end

      it '不衛生(filthy)なエリアでは健康な個体が発病すること' do
        z = build_adult(zebra)
        savanna.soil(80)
        run(savanna, [z])
        expect(z).to be_sick
      end

      it '清潔なエリアでは発病しないこと' do
        z = build_adult(zebra)
        run(savanna, [z])
        expect(z).not_to be_sick
      end

      it '群れ性の個体を一頭だけ収容すると、孤独で日々ストレスが増すこと' do
        lone = build_adult(zebra)
        expect { run(savanna, [lone]) }.to change { lone.stress_level }.by_at_least(1)
      end

      it '仲間がいて清潔・適温なら、ストレスは増えないこと' do
        a = build_adult(zebra, name: 'a')
        b = build_adult(zebra, name: 'b', sex: Animal::Sex.female)
        run(savanna, [a, b])
        expect(a).not_to be_stressed
      end

      it '刺激が日々 ENRICHMENT_DECAY_PER_DAY ぶん薄れること' do
        expect { run(savanna, []) }
          .to change { savanna.enrichment.level }.by(-described_class::ENRICHMENT_DECAY_PER_DAY)
      end
    end
  end
end
