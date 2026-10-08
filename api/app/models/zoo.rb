# frozen_string_literal: true

class Zoo < ApplicationRecord
  DEFAULT_NAME = 'OOP動物園'
  DEFAULT_ADMISSION_FEE_YEN = 2_000
  DEFAULT_FUNDS_YEN = 1_000_000

  attribute :admission_fee, ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc)
  attribute :opening_funds, ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc),
            default: -> { Money.zero }

  belongs_to :user
  has_many :acquirings, inverse_of: :zoo, dependent: :destroy
  has_many :constructings, inverse_of: :zoo, dependent: :destroy
  has_many :hirings, inverse_of: :zoo, dependent: :destroy
  has_many :enclosures, dependent: :destroy
  has_many :animals, dependent: :destroy
  has_many :keepers, dependent: :destroy
  has_many :veterinarians, dependent: :destroy
  has_many :operatings, -> { order(:day, :id) }, inverse_of: :zoo, dependent: :destroy

  validates :name, presence: { message: '動物園名は必須です' }

  def self.of(user)
    find_by(user:) || create!(
      user:,
      name: DEFAULT_NAME,
      admission_fee: Money.yen(DEFAULT_ADMISSION_FEE_YEN),
      opening_funds: Money.yen(DEFAULT_FUNDS_YEN)
    )
  end

  def reputation
    operatings.last&.reputation || Reputation.default
  end

  def reputation_factor
    reputation.factor
  end

  def reputation_score
    reputation.score
  end

  def day
    operatings.size
  end

  def season
    Season.on_day(day)
  end

  def admission_income(visitors)
    raise ArgumentError, '来園者数は0以上でなければなりません' if visitors.negative?

    admission_fee * visitors
  end

  def balance
    settle(operatings, outlays)
  end

  def closing_balance(day)
    settle(operatings.where(day: ..day), outlays.map { |outlay| outlay.where(day: ...day) })
  end

  def afford?(money)
    balance.yen >= money.yen
  end

  def authorize_payment(money)
    raise Errors::InsufficientFunds, "残高#{balance}では#{money}を支払えません" unless afford?(money)
  end

  def bankrupt?
    balance.negative?
  end

  def change_admission_fee(fee)
    self.admission_fee = fee
    self
  end

  def to_s
    name
  end

  private

  def outlays
    [acquirings, constructings, hirings]
  end

  def settle(operatings, outlays)
    Balance.new(
      opening_funds.yen + yen_sum(operatings, :income) - yen_sum(operatings, :cost) -
      outlays.sum { |outlay| yen_sum(outlay, :cost) }
    )
  end

  def yen_sum(records, column)
    return 0 if new_record?

    records.sum(column).yen
  end
end
