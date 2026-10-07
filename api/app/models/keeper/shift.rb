# frozen_string_literal: true

class Keeper
  class Shift
    include ValueObject

    LENGTH_MINUTES = 480

    attr_reader :worked_minutes

    def self.fresh
      new(0)
    end

    def initialize(worked_minutes)
      valid = worked_minutes.is_a?(Integer) && worked_minutes.between?(0, LENGTH_MINUTES)
      raise ArgumentError, "勤務時間は0〜#{LENGTH_MINUTES}分の整数でなければなりません" unless valid

      @worked_minutes = worked_minutes
      freeze
    end

    def remaining_minutes
      LENGTH_MINUTES - @worked_minutes
    end

    def allows?(minutes)
      minutes <= remaining_minutes
    end

    def worked(minutes)
      raise ArgumentError, '作業時間は0以上でなければなりません' if minutes.negative?

      self.class.new(@worked_minutes + minutes)
    end

    def to_s
      "#{@worked_minutes}/#{LENGTH_MINUTES}分"
    end

    protected

    def components
      [@worked_minutes]
    end
  end
end
