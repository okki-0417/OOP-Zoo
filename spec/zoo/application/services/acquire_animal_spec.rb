# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AcquireAnimal do
  describe '#call' do
    subject(:result) { described_class.new(command:).call }

    let(:command) { Factory::AcquireAnimalCommand.with_bind(species_code:, sex:, name:, zoo:) }
    let(:sex) { 'male' }
    let(:name) { 'モンタ' }
    let(:zoo) { Factory::ZooRepository.build(funds: 100_000) }

    context '存在しない動物の種が与えられた時' do
      let(:species_code) { 'dragon' }

      it '種が見つからないエラーになり、個体は保存されないこと' do
        expect(result.error).to be_a(Zoo::Application::Errors::SpeciesNotFound)
        expect(command.animals.all).to be_empty
      end
    end

    context '存在する動物の種が与えられた時' do
      let(:species_code) { 'japanese_macaque' }
      context 'Animal の初期化に失敗した時（sex が不正な値のとき）' do
        let(:sex) { 'invalid' }

        it 'InvalidValue エラーになり、個体は保存されないこと' do
          expect(result.error).to be_a(Zoo::Domain::Errors::InvalidValue)
          expect(command.animals.all).to be_empty
        end
      end

      context 'Animal の初期化に成功した時' do
        context '残高 100,000円の動物園が 20,550円のニホンザル「モンタ」を取得した時' do
          let(:rest_balance) { 79_450 }
          it 'success になり、value が name "モンタ" の Animal であり、その id で「モンタ」が保存され、残高が 79,450円になること' do
            expect(result).to be_success
            expect(result.value.name).to eq(name)
            expect(command.animals.find(result.value.id).name).to eq(name)
            expect(command.zoo.load.balance).to eq(Zoo::Domain::Shared::Balance.new(rest_balance))
          end
        end
      end
    end
  end
end
