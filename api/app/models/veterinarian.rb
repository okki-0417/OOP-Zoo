# frozen_string_literal: true

class Veterinarian < ApplicationRecord
  SIGNING_FEE_YEN = 30_000
  DAILY_SALARY_YEN = 12_000

  validates :name, presence: { message: '獣医名は必須です' }

  def self.signing_fee
    Money.yen(SIGNING_FEE_YEN)
  end

  def salary
    Money.yen(DAILY_SALARY_YEN)
  end

  def job_title
    '獣医'
  end

  def to_s
    "獣医 #{name}"
  end
end
