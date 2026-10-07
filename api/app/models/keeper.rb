# frozen_string_literal: true

class Keeper < ApplicationRecord
  SIGNING_FEE_YEN = 20_000
  DAILY_SALARY_YEN = 12_000

  has_many :assignments, dependent: :destroy
  has_many :enclosures, -> { order(:id) }, through: :assignments

  attribute :specialties, ListType.new(load: TaxonClass.method(:new), dump: :value.to_proc)

  validates :name, presence: { message: '飼育員名は必須です' }
  validates :specialties, presence: { message: '専門分野を1つ以上指定してください' }

  def self.signing_fee
    Money.yen(SIGNING_FEE_YEN)
  end

  def salary
    Money.yen(DAILY_SALARY_YEN)
  end

  def job_title
    '飼育員'
  end

  def available_for?(minutes)
    shift.allows?(minutes)
  end

  def clock_in(minutes)
    unless available_for?(minutes)
      raise Errors::WorkNotAllowed, "飼育員#{name}は今日の勤務時間が足りません(残り#{remaining_minutes}分)"
    end

    self.worked_minutes = shift.worked(minutes).worked_minutes
    self
  end

  def remaining_minutes
    shift.remaining_minutes
  end

  def end_shift
    self.worked_minutes = Shift.fresh.worked_minutes
    self
  end

  def specialized_in?(taxon_class)
    specialties.include?(taxon_class)
  end

  def in_charge_of?(enclosure)
    enclosures.include?(enclosure)
  end

  def specialties_label
    specialties.map(&:label).join('・')
  end

  def to_s
    "飼育員 #{name}(#{specialties_label}担当)"
  end

  private

  def shift
    Shift.new(worked_minutes)
  end
end
