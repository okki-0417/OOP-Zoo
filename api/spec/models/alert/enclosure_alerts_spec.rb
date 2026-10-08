# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alert::EnclosureAlerts do
  describe '#to_a' do
    subject(:alerts) { described_class.new(occupancy: Occupancy.new(enclosure: hill, occupants:), keepers:).to_a }

    let(:hill) { build(:enclosure, name: 'ライオンの丘') }
    let(:occupants) { [build(:animal)] }
    let(:keepers) { [build(:keeper)] }

    context '清潔で刺激も足り、担当の飼育員がいるとき' do
      it '空配列を返すこと' do
        expect(alerts).to eq([])
      end
    end

    context '担当の飼育員がいないとき' do
      let(:keepers) { [] }

      context '生きている動物がいるとき' do
        it 'エリアを対象に kind=:unassigned・severity=:warning・"担当の飼育員がいません。日々の見回りが行われません" を返すこと' do
          expect(alerts).to contain_exactly(
            { severity: :warning, kind: :unassigned, subject_type: :enclosure, subject: hill,
              message: '担当の飼育員がいません。日々の見回りが行われません' }
          )
        end
      end

      context '死亡した動物しかいないとき' do
        let(:occupants) { [build(:animal).die] }

        it '空配列を返すこと' do
          expect(alerts).to eq([])
        end
      end
    end

    context '80汚れたとき' do
      before { hill.soil(80) }

      it 'kind=:filthy・severity=:warning・"不潔です。同居する動物に寄生虫がまん延します" を返すこと' do
        expect(alerts).to contain_exactly(
          include(severity: :warning, kind: :filthy, message: '不潔です。同居する動物に寄生虫がまん延します')
        )
      end
    end

    context '刺激が80減ったとき' do
      before { hill.deplete_enrichment(80) }

      it 'kind=:barren・severity=:notice・"刺激が乏しく、動物が退屈しています" を返すこと' do
        expect(alerts).to contain_exactly(
          include(severity: :notice, kind: :barren, message: '刺激が乏しく、動物が退屈しています')
        )
      end
    end

    context '定員1のエリアにライオンが2頭いるとき' do
      let(:hill) { build(:enclosure, capacity: 1) }
      let(:occupants) { build_list(:animal, 2) }

      it 'kind=:overcrowded・severity=:warning・"過密です。ストレスと闘争が増えます" を返すこと' do
        expect(alerts).to contain_exactly(
          include(severity: :warning, kind: :overcrowded, message: '過密です。ストレスと闘争が増えます')
        )
      end
    end
  end
end
