# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Shared
      RSpec.describe Balance do
        it '収益を足すと残高が増えること' do
          expect((Balance.zero + Money.yen(5_000)).yen).to eq(5_000)
        end

        it '残高を超えて支出すると赤字(負)になり negative? が true を返すこと' do
          balance = Balance.new(1_000) - Money.yen(3_000)

          expect(balance.yen).to eq(-2_000)
          expect(balance).to be_negative
        end

        it '赤字残高は符号付きで整形されること(-¥2,000)' do
          expect((Balance.zero - Money.yen(2_000)).to_s).to eq('-¥2,000')
        end
      end
    end
  end
end
