# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AcquireAnimal do
  describe '#call' do
    subject(:result) { call_service(command, tools:) }

    let(:tools) { build_tools(funds: 100_000) }
    let(:command) { Zoo::Application::Commands::AcquireAnimalCommand.new(species_code:, name: 'モンタ', sex:) }
    let(:sex) { 'male' }

    context '存在しない動物の種が与えられた時' do
      let(:species_code) { 'dragon' }

      it '種が見つからないエラーになり、個体は保存されないこと' do
        expect(result.error).to be_a(Zoo::Application::Errors::SpeciesNotFound)
        expect(tools.animals.all).to be_empty
      end
    end

    context '存在する動物の種が与えられた時' do
      let(:species_code) { 'japanese_macaque' }

      context 'Animal の初期化に失敗した時（sex が不正な値のとき）' do
        let(:sex) { 'invalid' }

        it 'InvalidValue エラーになり、個体は保存されないこと' do
          expect(result.error).to be_a(Zoo::Domain::Errors::InvalidValue)
          expect(tools.animals.all).to be_empty
        end
      end

      context 'Animal の初期化に成功した時' do
        context '残高 100,000円の動物園が 20,550円のニホンザル「モンタ」を取得した時' do
          it 'success になり、value が name "モンタ" の AnimalProfile で、その id で「モンタ」が保存され、残高が 79,450円になること' do
            expect(result).to be_success
            expect(result.value).to be_a(Zoo::Application::ReadModels::AnimalProfile).and have_attributes(name: 'モンタ')
            expect(tools.animals.find(result.value.id).name).to eq('モンタ')
            expect(tools.zoo.load.balance).to eq(Zoo::Domain::Shared::Balance.new(79_450))
          end
        end
      end
    end
  end
end
