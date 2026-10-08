# frozen_string_literal: true

class Operating < ApplicationRecord
  class Expense < ApplicationRecord
    belongs_to :operating

    attribute :category, ValueType.new(Category, dump: ->(category) { category.value.to_s })
    attribute :amount, ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc)
    attribute :quantity, default: 1

    validates :subject, presence: { message: '費目の対象は必須です' }
    validates :quantity, numericality: { only_integer: true, greater_than: 0, message: '数量は1以上の整数でなければなりません' }

    def to_s
      counted = quantity > 1 ? "#{subject}×#{quantity}" : subject
      "#{category} #{counted} #{amount}"
    end
  end
end
