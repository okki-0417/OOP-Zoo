# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Operating::Expense do
  subject(:expense) do
    described_class.new(category: Operating::Expense::Category.feed, subject: target, quantity:, amount:)
  end

  let(:target) { 'ライオン' }
  let(:quantity) { 3 }
  let(:amount) { Money.yen(4_500) }

  describe '.new' do
    it 'frozen であること' do
      expect(expense).to be_frozen
    end

    context 'quantity を省略したとき' do
      subject(:expense) do
        described_class.new(category: Operating::Expense::Category.upkeep, subject: 'サバンナ', amount: Money.yen(5_000))
      end

      it 'quantity が 1 になること' do
        expect(expense.quantity).to eq(1)
      end
    end

    context 'subject が空文字のとき' do
      let(:target) { '' }

      it '「対象は必須」の ArgumentError を投げること' do
        expect { expense }.to raise_error(ArgumentError, /対象は必須/)
      end
    end

    context 'quantity が 0 のとき' do
      let(:quantity) { 0 }

      it '「数量」の ArgumentError を投げること' do
        expect { expense }.to raise_error(ArgumentError, /数量/)
      end
    end

    context 'quantity が整数でない 1.5 のとき' do
      let(:quantity) { 1.5 }

      it '「数量」の ArgumentError を投げること' do
        expect { expense }.to raise_error(ArgumentError, /数量/)
      end
    end
  end

  describe '#==' do
    let(:other) do
      described_class.new(category: Operating::Expense::Category.feed, subject: 'ライオン', quantity: other_quantity,
                          amount: Money.yen(4_500))
    end

    context '費目・対象・数量・金額が同じとき' do
      let(:other_quantity) { 3 }

      it '等しいこと' do
        expect(expense).to eq(other)
      end
    end

    context '数量だけが 3 と 2 で違うとき' do
      let(:other_quantity) { 2 }

      it '等しくないこと' do
        expect(expense).not_to eq(other)
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
