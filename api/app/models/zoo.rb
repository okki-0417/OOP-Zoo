# frozen_string_literal: true

class Zoo < ApplicationRecord
  DEFAULT_NAME = 'OOP動物園'
  DEFAULT_ADMISSION_FEE_YEN = 2_000
  DEFAULT_FUNDS_YEN = 1_000_000

  attribute :admission_fee, ValueType.new(Money, load: Money.method(:yen), dump: :yen.to_proc)
  attribute :balance, ValueType.new(Balance, dump: :yen.to_proc),
            default: -> { Balance.zero }
  attribute :reputation, ValueType.new(Reputation, dump: :value.to_proc),
            default: -> { Reputation.default }

  belongs_to :user
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
      funds: Money.yen(DEFAULT_FUNDS_YEN)
    )
  end

  def funds=(money)
    self.balance = Balance.new(money.yen)
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

  def admit_visitors(count)
    raise ArgumentError, '来園者数は0以上でなければなりません' if count.negative?

    earned = admission_fee * count
    self.balance += earned
    earned
  end

  def spend(money)
    self.balance -= money
    balance
  end

  def afford?(money)
    balance.yen >= money.yen
  end

  def purchase(money)
    raise Errors::InsufficientFunds, "残高#{balance}では#{money}を支払えません" unless afford?(money)

    self.balance -= money
    balance
  end

  def bankrupt?
    balance.negative?
  end

  def gain_reputation(amount)
    self.reputation = reputation.gain(amount)
    self
  end

  def update_reputation(reputation)
    self.reputation = reputation
    self
  end

  def change_admission_fee(fee)
    self.admission_fee = fee
    self
  end

  def to_s
    name
  end
end
