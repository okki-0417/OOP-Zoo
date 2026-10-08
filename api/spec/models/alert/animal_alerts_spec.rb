# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alert::AnimalAlerts do
  describe '#to_a' do
    subject(:alerts) do
      described_class.new(animal: lion, occupancy: Occupancy.new(enclosure: hill, occupants:), season: Season.on_day(0)).to_a
    end

    let(:lion) { build(:animal, name: 'レオ') }
    let(:mate) { build(:animal, :female, name: 'ナラ') }
    let(:hill) { build(:enclosure, name: 'ライオンの丘', celsius: 25) }
    let(:occupants) { [lion, mate] }

    context '健康で快適なエリアにいるとき' do
      it '空配列を返すこと' do
        expect(alerts).to eq([])
      end
    end

    context '肺炎にかかっているとき' do
      let(:lion) { build(:animal, name: 'レオ').fall_ill(IllnessCatalog.pneumonia) }

      it "予後 kind=:guarded・severity=:warning・'このままだと12日以内に病死する見込みです' を返すこと" do
        expect(alerts).to include(
          include(kind: :guarded, severity: :warning, message: 'このままだと12日以内に病死する見込みです')
        )
      end

      context '感染しうる同居個体がいるとき' do
        it "kind=:sick・'肺炎にかかっています。同居個体にうつるおそれがあります' を返すこと" do
          expect(alerts).to include(
            include(kind: :sick, severity: :warning, message: '肺炎にかかっています。同居個体にうつるおそれがあります')
          )
        end
      end

      context '同居個体がいないとき' do
        let(:occupants) { [lion] }

        it "kind=:sick・'肺炎にかかっています' を返すこと" do
          expect(alerts).to include(include(kind: :sick, message: '肺炎にかかっています'))
        end
      end

      context '最大体力が10のとき' do
        let(:lion) { build(:animal, name: 'レオ', max_health: 10).fall_ill(IllnessCatalog.pneumonia) }

        it '予後 kind=:grave・severity=:critical を返すこと' do
          expect(alerts).to include(include(kind: :grave, severity: :critical))
        end
      end
    end

    context '空腹度が100増えたとき' do
      let(:lion) { build(:animal, name: 'レオ').get_hungrier(100) }

      it "kind=:starving・severity=:critical・'飢餓状態です。体力が日々削られています' を返すこと" do
        expect(alerts).to include(
          include(kind: :starving, severity: :critical, message: '飢餓状態です。体力が日々削られています')
        )
      end
    end

    context '空腹度が85増えたとき' do
      let(:lion) { build(:animal, name: 'レオ').get_hungrier(85) }

      it 'kind=:hungry・severity=:warning を返すこと' do
        expect(alerts).to include(include(kind: :hungry, severity: :warning))
      end
    end

    context '栄養の精算を3回続けたとき' do
      before { 3.times { lion.settle_nutrition } }

      it "kind=:malnourished・'栄養失調です。餌の種類が足りていません' を返すこと" do
        expect(alerts).to include(include(kind: :malnourished, message: '栄養失調です。餌の種類が足りていません'))
      end
    end

    context 'ストレスが60のとき' do
      before { lion.add_stress(60) }

      it "kind=:stressed・severity=:notice・'ストレスを抱えています' を返すこと" do
        expect(alerts).to include(include(kind: :stressed, severity: :notice, message: 'ストレスを抱えています'))
      end
    end

    context 'ストレスが90のとき' do
      before { lion.add_stress(90) }

      it "kind=:stressed・severity=:warning・'強いストレスで体力を削られています' を返すこと" do
        expect(alerts).to include(
          include(kind: :stressed, severity: :warning, message: '強いストレスで体力を削られています')
        )
      end
    end

    context '-30℃の氷室にいるとき' do
      let(:hill) { build(:enclosure, name: '氷室', celsius: -30) }

      it "kind=:climate・severity=:warning・'氷室の体感-30.0℃は生存可能域の外です' を返すこと" do
        expect(alerts).to include(
          include(kind: :climate, severity: :warning, message: '氷室の体感-30.0℃は生存可能域の外です')
        )
      end
    end

    context '11℃の岩場にいるとき' do
      let(:hill) { build(:enclosure, name: '岩場', celsius: 11) }

      it "kind=:climate・severity=:notice・'岩場の体感11.0℃は快適域から外れています' を返すこと" do
        expect(alerts).to include(
          include(kind: :climate, severity: :notice, message: '岩場の体感11.0℃は快適域から外れています')
        )
      end
    end

    context '受胎して妊娠期間を満了したとき' do
      let(:lion) { build(:animal, :female, name: 'ナラ') }

      before do
        lion.conceive
        lion.gestate(SpeciesCatalog.lion.gestation_period_days)
      end

      it "kind=:due・severity=:notice・'出産(孵化)の時期を迎えています' を返すこと" do
        expect(alerts).to include(include(kind: :due, severity: :notice, message: '出産(孵化)の時期を迎えています'))
      end
    end
  end
end
