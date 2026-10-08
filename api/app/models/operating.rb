# frozen_string_literal: true

class Operating < ApplicationRecord
  belongs_to :zoo
  has_many :expenses, -> { order(:id) }, inverse_of: :operating, dependent: :destroy

  MONEY = ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc)

  attribute :income, MONEY
  attribute :cost, MONEY
  attribute :balance, ValueType.new(Balance, dump: :yen.to_proc)
  attribute :casualties, default: -> { [] }

  def net_income
    Balance.new(income.yen - cost.yen)
  end

  def to_s
    "#{day}日目: 来園#{visitors}人 純益#{net_income}"
  end
end
