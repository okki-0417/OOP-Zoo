# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Alert::StaffingAlerts do
  describe '#to_a' do
    subject(:alerts) { described_class.new(zoo:, occupants: [lion], keepers:, veterinarians:).to_a }

    let(:zoo) { build(:zoo) }
    let(:lion) { build(:animal) }
    let(:keepers) { [build(:keeper)] }
    let(:veterinarians) { [build(:veterinarian)] }

    context '哺乳類の飼育員と獣医がそろっているとき' do
      it '空配列を返すこと' do
        expect(alerts).to eq([])
      end
    end

    context '飼育員が鳥類専門の1人だけのとき' do
      let(:keepers) { [build(:keeper, specialties: [TaxonClass.bird])] }

      it '園を対象に kind=:no_keeper・severity=:warning・"哺乳類を世話できる飼育員がいません" を返すこと' do
        expect(alerts).to contain_exactly(
          { severity: :warning, kind: :no_keeper, subject_type: :zoo, subject: zoo,
            message: '哺乳類を世話できる飼育員がいません' }
        )
      end
    end

    context '病気の個体がいるとき' do
      let(:lion) { build(:animal).fall_ill(IllnessCatalog.cold) }

      context '獣医が0人のとき' do
        let(:veterinarians) { [] }

        it '園を対象に kind=:no_veterinarian・"病気の動物がいますが、獣医がいません" を返すこと' do
          expect(alerts).to contain_exactly(
            { severity: :warning, kind: :no_veterinarian, subject_type: :zoo, subject: zoo,
              message: '病気の動物がいますが、獣医がいません' }
          )
        end
      end

      context '獣医が1人いるとき' do
        it 'kind=:no_veterinarian を返さないこと' do
          expect(alerts.pluck(:kind)).not_to include(:no_veterinarian)
        end
      end
    end
  end
end
