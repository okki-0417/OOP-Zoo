# frozen_string_literal: true

module Zoo
  module Domain
    class ConservationStatus
      include Shared::ValueObject
      include Comparable

      STATUSES = {
        least_concern: { code: 'LC', label: '低危険' },
        near_threatened: { code: 'NT', label: '準絶滅危惧' },
        vulnerable: { code: 'VU', label: '危急' },
        endangered: { code: 'EN', label: '絶滅危惧' },
        critically_endangered: { code: 'CR', label: '深刻な絶滅危惧' },
        extinct_in_the_wild: { code: 'EW', label: '野生絶滅' },
        extinct: { code: 'EX', label: '絶滅' }
      }.freeze

      ORDER = STATUSES.keys.freeze

      attr_reader :value

      STATUSES.each_key do |key|
        define_singleton_method(key) { new(key) }
      end

      def initialize(value)
        symbol = value.to_sym
        raise ArgumentError, "未知の保全状況です: #{value}" unless STATUSES.key?(symbol)

        @value = symbol
        freeze
      end

      def threatened?
        %i[vulnerable endangered critically_endangered].include?(@value)
      end

      def extinct?
        %i[extinct_in_the_wild extinct].include?(@value)
      end

      def rank
        ORDER.index(@value)
      end

      def <=>(other)
        return nil unless other.is_a?(ConservationStatus)

        rank <=> other.rank
      end

      def code
        STATUSES.fetch(@value)[:code]
      end

      def label
        STATUSES.fetch(@value)[:label]
      end

      def to_s
        "#{code}(#{label})"
      end

      protected

      def components
        [@value]
      end
    end
  end
end
