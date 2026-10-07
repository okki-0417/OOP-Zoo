# frozen_string_literal: true

module Types
  class Zoo < BaseObject
    field :name, String, null: false
    field :day, Integer, null: false
    field :balance, Integer, null: false
    field :reputation, Integer, null: false, method: :reputation_score
    field :admission_fee, Integer, null: false
    field :exhibit_condition, Integer, null: false
    field :experience, Integer, null: false
    field :expected_visitors, Integer, null: false
    field :reputation_drift, Float, null: false
    field :reputation_decay, Float, null: false
    field :reputation_swing_limit, Integer, null: false
    field :visitors_for_full_swing, Integer, null: false
    field :buzz, Integer, null: false
    field :spectacle, Integer, null: false
    field :spectacle_saturation, Integer, null: false
    field :willingness_to_pay, Integer, null: false

    def balance
      object.balance.yen
    end

    def admission_fee
      object.admission_fee.yen
    end

    def exhibit_condition
      ::ExhibitCondition.new(on_exhibit).score
    end

    def experience
      ::Experience.new(on_exhibit:, fee: object.admission_fee).score
    end

    def expected_visitors
      ::VisitorAttraction.new(on_exhibit:, zoo: object).expected_visitors
    end

    def reputation_drift
      object.reputation.after_day(experience:, exposure: expected_visitors).value -
        object.reputation.value - reputation_decay
    end

    def reputation_decay
      object.reputation.after_day(experience:, exposure: 0).value - object.reputation.value
    end

    def reputation_swing_limit
      ::Zoo::Reputation::DRIFT_CAP * ::Zoo::Reputation::DOWN_MULTIPLIER
    end

    def visitors_for_full_swing
      ::Zoo::Reputation::EXPOSURE_REFERENCE
    end

    def spectacle
      ::Spectacle.new(on_exhibit:, buzz: object.buzz).value.round
    end

    def spectacle_saturation
      ::Spectacle::SATURATION
    end

    def willingness_to_pay
      attraction = ::VisitorAttraction
      spending = ::Spectacle.new(on_exhibit:, buzz: object.buzz).value *
                 attraction::WILLINGNESS_PER_SPECTACLE_YEN * object.reputation_factor
      (attraction::WILLINGNESS_BASE_YEN + spending).round
    end

    private

    def on_exhibit
      @on_exhibit ||= ::Occupancy.all.flat_map(&:to_a)
    end
  end
end
