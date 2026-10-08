# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ZooDay do
  describe '.of' do
    subject(:assembled) { described_class.of(zoo, random: Random.new(0)) }

    let(:zoo) { create(:zoo) }
    let!(:hill) { create(:enclosure, name: '丘', zoo:) }
    let!(:lion) { create(:animal, name: 'レオ', enclosure: hill, zoo:) }
    let!(:keeper) { create(:keeper, zoo:) }

    before do
      create(:animal, enclosure: create(:enclosure))
      create(:keeper)
    end

    it 'ほかの園のものを含めず、渡した園の保存済みのエリア・動物・飼育員から1日を組み立てること' do
      expect(assembled.zoo).to eq(zoo)
      expect(assembled.enclosures).to eq([hill])
      expect(assembled.on_exhibit).to eq([lion])
      expect(assembled.keepers).to eq([keeper])
    end

    context 'その日に絶滅危惧種のライオンを受け入れていたとき' do
      before do
        create(:acquiring, zoo:, animal: create(:animal, zoo:), day: zoo.day)
        allow(ReputationEvent::ConservationAcquisition).to receive(:new).and_call_original
      end

      it '#run でその受け入れを評判に1件反映すること' do
        assembled.run

        expect(ReputationEvent::ConservationAcquisition).to have_received(:new).once
      end
    end

    context '前日に絶滅危惧種のライオンを受け入れていたとき' do
      before do
        create(:acquiring, zoo:, animal: create(:animal, zoo:), day: zoo.day)
        described_class.of(zoo, random: Random.new(0)).run
        allow(ReputationEvent::ConservationAcquisition).to receive(:new).and_call_original
      end

      it '#run でその受け入れを評判に反映しないこと' do
        assembled.run

        expect(ReputationEvent::ConservationAcquisition).not_to have_received(:new)
      end
    end

    context '前日の営業が保存済みのとき' do
      before { described_class.of(zoo, random: Random.new(0)).run }

      it '#run で day=2 の Operating をその園の記録として返すこと' do
        expect(assembled.run).to have_attributes(day: 2, zoo:)
      end
    end
  end

  subject(:zoo_day) do
    described_class.new(
      zoo:, occupancies: [Occupancy.new(enclosure: hill, occupants:)], keepers: [keeper], veterinarians: [],
      acquirings:, random: Random.new(0)
    )
  end

  let(:acquirings) { [] }

  let(:zoo) { build(:zoo) }
  let(:hill) { build(:enclosure, name: '丘') }
  let(:lion) { build(:animal, name: 'レオ') }
  let(:occupants) { [lion] }
  let(:keeper) { build(:keeper) }

  describe '#run' do
    subject(:operating) { zoo_day.run }

    it 'zoo.day を1にし、day=1 の Operating を返すこと' do
      expect(operating).to be_a(Operating).and have_attributes(day: 1)
      expect(zoo.day).to eq(1)
    end

    it 'expenses に payroll・upkeep・feed が並び、cost がその合計であること' do
      expect(operating.expenses.map { |expense| expense.category.value }).to contain_exactly(:payroll, :upkeep, :feed)
      expect(operating.cost).to eq(Money.yen(operating.expenses.sum { |expense| expense.amount.yen }))
    end

    it '丘はレオ1頭ぶん汚れて cleanliness_level=99、刺激が2減って enrichment=98 になること' do
      operating

      expect(hill.cleanliness_level).to eq(99)
      expect(hill.enrichment.level).to eq(98)
    end

    context 'その日に保全目的の受け入れがあったとき' do
      let(:acquirings) { [instance_double(Acquiring, conservation?: true)] }

      before { allow(ReputationEvent::ConservationAcquisition).to receive(:new).and_call_original }

      it 'その日の終わりの評判に保全の受け入れを1件反映すること' do
        operating

        expect(ReputationEvent::ConservationAcquisition).to have_received(:new).once
      end
    end

    context 'その日に取引での購入だけがあったとき' do
      let(:acquirings) { [instance_double(Acquiring, conservation?: false)] }

      before { allow(ReputationEvent::ConservationAcquisition).to receive(:new).and_call_original }

      it '保全の受け入れを評判に反映しないこと' do
        operating

        expect(ReputationEvent::ConservationAcquisition).not_to have_received(:new)
      end
    end

    context '飼育員が100分働いているとき' do
      before { keeper.clock_in(100) }

      it '1日の終わりに worked_minutes を0にリセットすること' do
        operating

        expect(keeper.worked_minutes).to eq(0)
      end
    end

    it 'Operating・園・エリア・動物・飼育員を保存すること' do
      expect(operating).to be_persisted
      expect([zoo, hill, lion, keeper]).to all(be_persisted)
    end

    context '体力1で空腹度100の個体がいるとき' do
      let(:dying) { build(:animal, max_health: 1).get_hungrier(100) }
      let(:occupants) { [dying] }

      it 'casualties にその個体を入れ、deaths=1 にすること' do
        expect(operating.casualties).to eq([dying])
        expect(operating.deaths).to eq(1)
      end
    end
  end

  describe '#enclosures / #on_exhibit / #keepers' do
    it '[丘]・[レオ]・[飼育員] を返すこと' do
      expect(zoo_day.enclosures).to eq([hill])
      expect(zoo_day.on_exhibit).to eq([lion])
      expect(zoo_day.keepers).to eq([keeper])
    end
  end
end
