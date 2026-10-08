# frozen_string_literal: true

class Hiring < ApplicationRecord
  belongs_to :zoo, inverse_of: :hirings
  belongs_to :employee, polymorphic: true

  attribute :cost, ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc)

  def perform
    employee.zoo = zoo
    self.day = zoo.day
    self.cost = employee.class.signing_fee
    zoo.authorize_payment(cost)
    employee.save!
    save!
    employee
  end

  def to_s
    "#{employee.name}を雇用"
  end
end
