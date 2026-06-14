# frozen_string_literal: true

module Zoo
  module Domain
    module Medical
      # 検疫(導入個体の隔離観察)を表す不変の値オブジェクト。
      #
      # 新規導入個体を一定期間隔離して観察し、感染症の園内持ち込みを防ぐ。観察期間を
      # 満たし、かつ病気が出ていないことが確認できて初めて群れへの合流を許す。
      class Quarantine
        include Shared::ValueObject

        # 規定の観察期間(日)。
        REQUIRED_DAYS = 30

        attr_reader :days_observed

        def self.begin
          new(0)
        end

        def initialize(days_observed)
          raise ArgumentError, '観察日数は0以上の整数でなければなりません' unless days_observed.is_a?(Integer) && !days_observed.negative?

          @days_observed = days_observed
          freeze
        end

        # 観察を日数ぶん進めた新しい検疫を返す。
        def observe(days)
          raise ArgumentError, '観察を進める日数は1以上でなければなりません' unless days.is_a?(Integer) && days >= 1

          self.class.new(@days_observed + days)
        end

        # 規定の観察期間を満たしたか。
        def period_complete?
          @days_observed >= REQUIRED_DAYS
        end

        # 観察完了までの残り日数。
        def days_remaining
          [REQUIRED_DAYS - @days_observed, 0].max
        end

        # 対象個体を群れへ合流させてよいか(観察完了かつ発病していない)。
        def safe_to_release?(animal)
          period_complete? && !animal.sick?
        end

        protected

        def components
          [@days_observed]
        end
      end
    end
  end
end
