# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::AcquireAnimal do
  describe '#call' do
    subject(:result) { described_class.new(command:).call }

    let(:command) { Services::Commands::AcquireAnimalCommand.new(species_code:, sex:, name:) }
    let(:sex) { 'male' }
    let(:name) { 'モンタ' }
    let!(:zoo) { create_zoo(funds: 100_000) }

    context '存在しない動物の種が与えられた時' do
      let(:species_code) { 'dragon' }

      it '種が見つからないエラーになり、個体は保存されないこと' do
        expect(result.error).to be_a(Services::Errors::SpeciesNotFound)
        expect(Animal.count).to eq(0)
      end
    end

    context '存在する動物の種が与えられた時' do
      let(:species_code) { 'japanese_macaque' }

      context 'Animal の初期化に失敗した時（sex が不正な値のとき）' do
        let(:sex) { 'invalid' }

        it 'InvalidValue エラーになり、個体は保存されず残高も変わらないこと' do
          expect(result.error).to be_a(Errors::InvalidValue)
          expect(Animal.count).to eq(0)
          expect(zoo.reload.balance).to eq(Balance.new(100_000))
        end
      end

      context 'Animal の初期化に成功した時' do
        context '残高 100,000円の動物園が 20,550円のニホンザル「モンタ」を取得した時' do
          it 'success になり、value が name "モンタ" の Animal であり、その id で「モンタ」が保存され、残高が 79,450円になること' do
            expect(result).to be_success
            expect(result.value.name).to eq(name)
            expect(Animal.find(result.value.id).name).to eq(name)
            expect(zoo.reload.balance).to eq(Balance.new(79_450))
          end
        end
      end
    end
  end
end
