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
    field :spectacle, Integer, null: false
    field :spectacle_saturation, Integer, null: false
    field :spectacle_charisma, Integer, null: false
    field :spectacle_herd_bonus, Integer, null: false
    field :spectacle_buzz, Integer, null: false
    field :herds, [Herd], null: false
    field :buzzes, [Buzz], null: false
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
      ::VisitorAttraction.new(spectacle: spectacle_model, zoo: object).expected_visitors
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
      spectacle_model.value.round
    end

    def spectacle_saturation
      ::Spectacle::SATURATION
    end

    def willingness_to_pay
      attraction = ::VisitorAttraction
      spending = spectacle_model.value *
                 attraction::WILLINGNESS_PER_SPECTACLE_YEN * object.reputation_factor
      (attraction::WILLINGNESS_BASE_YEN + spending).round
    end

    def spectacle_charisma
      spectacle_model.charisma
    end

    def spectacle_herd_bonus
      spectacle_model.herd_bonus.round
    end

    def spectacle_buzz
      spectacle_model.buzz.round
    end

    def herds
      spectacle_model.herds.select { |herd| herd.bonus.positive? }.sort_by { |herd| -herd.bonus }
    end

    def buzzes
      spectacle_model.buzzes.sort_by { |buzz| -buzz.amount }
    end

    private

    def occupancies
      @occupancies ||= ::Occupancy.of_zoo(object)
    end

    def on_exhibit
      @on_exhibit ||= occupancies.flat_map(&:to_a)
    end

    def spectacle_model
      @spectacle_model ||= ::Spectacle.of(occupancies, today: object.day)
    end
  end
end
