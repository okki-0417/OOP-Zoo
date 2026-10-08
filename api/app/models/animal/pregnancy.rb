# frozen_string_literal: true

class Animal
  class Pregnancy < ApplicationRecord
    belongs_to :dam, class_name: 'Animal', inverse_of: :pregnancies

    attribute :sex, ValueType.new(Sex, dump: ->(sex) { sex.value.to_s }), default: -> { Sex.random }

    enum :outcome, { delivered: 'delivered', miscarried: 'miscarried' }

    validates :gestation_days, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    def ongoing?
      outcome.nil?
    end

    def advance(days)
      raise ArgumentError, '経過日数は0以上でなければなりません' if days.negative?

      self.gestation_days += days
      self
    end

    def deliver
      self.outcome = :delivered
      self
    end

    def miscarry
      self.outcome = :miscarried
      self
    end

    def to_s
      "妊娠#{gestation_days}日"
    end
  end
end
