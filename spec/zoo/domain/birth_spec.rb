# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Birth do
      let(:lion) { SpeciesCatalog.lion }
      let(:sire) { build_adult(lion, name: 'レオ', sex: Animal::Sex.male) }
      let(:dam)  { build_adult(lion, name: 'ナラ', sex: Animal::Sex.female) }

      def ready_dam(inbreeding: 0.0)
        dam.conceive(inbreeding: inbreeding)
        dam.gestate(lion.gestation_period_days)
        dam
      end

      describe '#deliver' do
        it '子を1頭生成し、両親を parent_ids に持つこと' do
          ready_dam
          offspring = described_class.new(sire:, dam:, name: 'シンバ').deliver.offspring
          expect(offspring.parent_ids).to contain_exactly(sire.id, dam.id)
          expect(offspring.age_in_days).to eq(0)
        end

        it 'dam の妊娠を解くこと' do
          ready_dam
          described_class.new(sire:, dam:).deliver
          expect(dam).not_to be_expecting
        end

        it 'name を省略すると種名ベースの仮名が付くこと' do
          ready_dam
          offspring = described_class.new(sire:, dam:).deliver.offspring
          expect(offspring.name).to eq("#{lion.name_ja}の赤ちゃん")
        end

        it 'dam に Birth イベントを1件記録すること' do
          ready_dam
          described_class.new(sire:, dam:, day: 120, season: Season.autumn).deliver
          event = dam.pull_events.last
          expect(event).to be_a(Events::Birth)
          expect(event.occurred_on).to eq(120)
          expect(event.season).to eq(Season.autumn)
        end

        it '近交係数が高いほど虚弱に(最大体力が低く)生まれること' do
          healthy = described_class.new(sire:, dam: ready_dam).deliver.offspring
          inbred_dam = build_adult(lion, name: '母2', sex: Animal::Sex.female)
          inbred_dam.conceive(inbreeding: 0.25)
          inbred_dam.gestate(lion.gestation_period_days)
          inbred = described_class.new(sire:, dam: inbred_dam).deliver.offspring
          expect(inbred.max_health).to be < healthy.max_health
        end

        it 'まだ出産時期でない dam には BreedingNotAllowed になること' do
          dam.conceive
          expect { described_class.new(sire:, dam:).deliver }.to raise_error(Errors::BreedingNotAllowed)
        end
      end

      describe '#deliver_litter' do
        it '産仔数ぶんの子を生成し、全頭が同じ両親を持つこと' do
          ready_dam
          litter = described_class.new(sire:, dam:, name: '仔').deliver_litter.offspring
          expect(litter.size).to eq(lion.litter_size)
          litter.each { |cub| expect(cub.parent_ids).to contain_exactly(sire.id, dam.id) }
        end
      end
    end
  end
end
