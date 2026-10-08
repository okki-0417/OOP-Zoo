# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Operating::Expense do
  subject(:expense) do
    described_class.new(category: Operating::Expense::Category.feed, subject: target, quantity:, amount:)
  end

  let(:target) { 'ライオン' }
  let(:quantity) { 3 }
  let(:amount) { Money.yen(4_500) }

  describe '.new' do
    context 'quantity を省略したとき' do
      subject(:expense) do
        described_class.new(category: Operating::Expense::Category.upkeep, subject: 'サバンナ', amount: Money.yen(5_000))
      end

      it 'quantity が 1 になること' do
        expect(expense.quantity).to eq(1)
      end
    end
  end

  describe '#valid?' do
    subject(:expense) do
      described_class.new(operating: Operating.none_yet, category: Operating::Expense::Category.feed, subject: target, quantity:, amount:)
    end

    context '対象・数量がそろっているとき' do
      it 'true を返すこと' do
        expect(expense).to be_valid
      end
    end

    context 'subject が空文字のとき' do
      let(:target) { '' }

      it 'false を返し、subject に「費目の対象は必須です」が付くこと' do
        expect(expense).not_to be_valid
        expect(expense.errors[:subject]).to eq(['費目の対象は必須です'])
      end
    end

    context 'quantity が 0 のとき' do
      let(:quantity) { 0 }

      it 'false を返し、quantity に「数量は1以上の整数でなければなりません」が付くこと' do
        expect(expense).not_to be_valid
        expect(expense.errors[:quantity]).to eq(['数量は1以上の整数でなければなりません'])
      end
    end

    context 'quantity が整数でない 1.5 のとき' do
      let(:quantity) { 1.5 }

      it 'false を返すこと' do
        expect(expense).not_to be_valid
      end
    end
  end

  describe '#to_s' do
    context '数量が 3 のとき' do
      it "'飼料費 ライオン×3 ¥4,500' を返すこと" do
        expect(expense.to_s).to eq('飼料費 ライオン×3 ¥4,500')
      end
    end

    context '数量が 1 のとき' do
      let(:quantity) { 1 }
      let(:amount) { Money.yen(1_500) }

      it "数量を省いた '飼料費 ライオン ¥1,500' を返すこと" do
        expect(expense.to_s).to eq('飼料費 ライオン ¥1,500')
      end
    end
  end
end

RSpec.describe Operating::Expense::Category do
  describe '.payroll / .upkeep / .feed' do
    it 'それぞれラベル 人件費・施設維持費・飼料費 を持つこと' do
      expect([described_class.payroll, described_class.upkeep, described_class.feed].map(&:label))
        .to eq(%w[人件費 施設維持費 飼料費])
    end
  end

  describe '.new' do
    context '文字列 "feed" のとき' do
      it '.feed と等しいこと' do
        expect(described_class.new('feed')).to eq(described_class.feed)
      end
    end

    context '未知の費目 :tax のとき' do
      it '「未知の費目」の InvalidValue を投げること' do
        expect { described_class.new(:tax) }.to raise_error(Errors::InvalidValue, /未知の費目/)
      end
    end
  end

  describe '#to_s' do
    it '.payroll は "人件費" を返すこと' do
      expect(described_class.payroll.to_s).to eq('人件費')
    end
  end
end
