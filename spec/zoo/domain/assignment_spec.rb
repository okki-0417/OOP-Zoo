# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    RSpec.describe Assignment do
      let(:enclosure) do
        Enclosure.new(name: 'サバンナ', temperature: Shared::Temperature.celsius(28), capacity: 4)
      end
      let(:tanaka) { Keeper.new(name: '田中', specialties: [TaxonClass.mammal]) }
      let(:suzuki) { Keeper.new(name: '鈴木', specialties: [TaxonClass.mammal]) }

      describe '#assigned?' do
        it '担当陣に同じ id の飼育員がいれば真を返すこと' do
          expect(described_class.new(enclosure, [tanaka]).assigned?(tanaka.id)).to be(true)
        end

        it '担当陣にいない飼育員には偽を返すこと' do
          expect(described_class.new(enclosure, [tanaka]).assigned?(suzuki.id)).to be(false)
        end

        it '担当陣を省略すると誰も担当していないこと' do
          expect(described_class.new(enclosure).assigned?(tanaka.id)).to be(false)
        end
      end
    end
  end
end
