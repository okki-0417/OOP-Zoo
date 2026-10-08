# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alert do
  describe '.of' do
    subject(:alerts) { described_class.of(zoo) }

    let(:zoo) { create(:zoo) }
    let(:hill) { create(:enclosure, zoo:) }

    before do
      create(:veterinarian, zoo:)
      create(:keeper, zoo:).enclosures << hill
      create(:animal, enclosure: hill, zoo:)
      create(:animal, name: '迷子', zoo:)
      create(:animal, name: '故', zoo:).die.save!
      create(:animal, name: 'よその迷子')
    end

    it '渡した園の保存済みの記録から組み立て、生きていてどのエリアにもいない迷子だけを kind=:unhoused で返すこと' do
      expect(alerts).to contain_exactly(
        { severity: :warning, kind: :unhoused, subject_type: :animal, subject: Animal.find_by!(name: '迷子'),
          message: 'どのエリアにも収容されていません' }
      )
    end
  end

  describe '#to_a' do
    subject(:alerts) do
      described_class.new(
        zoo:, occupancies: [Occupancy.new(enclosure: hill, occupants: [lion])], keepers:,
        veterinarians: [build(:veterinarian)], unhoused:
      ).to_a
    end

    let(:zoo) { build(:zoo) }
    let(:keeper) { build(:keeper) }
    let(:keepers) { [keeper] }
    let(:hill) { build(:enclosure, name: 'ライオンの丘', keepers: [keeper]) }
    let(:lion) { build(:animal, name: 'レオ') }
    let(:unhoused) { [] }

    context '健康な個体が快適なエリアにいて、担当の飼育員と獣医がそろっているとき' do
      it '空配列を返すこと' do
        expect(alerts).to eq([])
      end
    end

    context '残高が -¥5,000 のとき' do
      before { zoo.spend(Money.yen(zoo.balance.yen + 5_000)) }

      it "園を対象に kind=:insolvent・severity=:critical・'資金が赤字です(残高 -¥5,000)' を返すこと" do
        expect(alerts).to contain_exactly(
          { severity: :critical, kind: :insolvent, subject_type: :zoo, subject: zoo,
            message: '資金が赤字です(残高 -¥5,000)' }
        )
      end
    end

    context 'どのエリアにもいない迷子を渡したとき' do
      let(:unhoused) { [build(:animal, name: '迷子')] }

      it "迷子を対象に kind=:unhoused・severity=:warning・'どのエリアにも収容されていません' を返すこと" do
        expect(alerts).to contain_exactly(
          { severity: :warning, kind: :unhoused, subject_type: :animal, subject: unhoused.first,
            message: 'どのエリアにも収容されていません' }
        )
      end
    end

    context '残高 -¥1・飼育員0人・担当なしのエリアに、ストレス60で空腹度85のレオがいるとき' do
      let(:keepers) { [] }
      let(:hill) { build(:enclosure, name: 'ライオンの丘') }

      before do
        zoo.spend(Money.yen(zoo.balance.yen + 1))
        lion.add_stress(60)
        lion.get_hungrier(85)
      end

      it 'critical → warning → notice の順で、同じ warning では園への no_keeper を先に並べること' do
        expect(alerts.map { |alert| [alert[:severity], alert[:kind]] }).to eq(
          [%i[critical insolvent], %i[warning no_keeper], %i[warning unassigned], %i[warning hungry],
           %i[notice stressed]]
        )
      end
    end
  end
end
