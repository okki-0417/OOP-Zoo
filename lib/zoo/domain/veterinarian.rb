# frozen_string_literal: true

module Zoo
  module Domain
    class Veterinarian
      include Shared::Entity

      attr_reader :id, :name

      SIGNING_FEE_YEN = 30_000
      DAILY_SALARY_YEN = 12_000

      def self.signing_fee
        Shared::Money.yen(SIGNING_FEE_YEN)
      end

      def salary
        Shared::Money.yen(DAILY_SALARY_YEN)
      end

      def initialize(name:, id: Shared::Identifier.new)
        raise ArgumentError, '獣医名は必須です' if name.to_s.empty?

        @id = id
        @name = name
      end

      def self.reconstitute(id:, name:)
        allocate.tap do |vet|
          vet.instance_variable_set(:@id, id)
          vet.instance_variable_set(:@name, name)
        end
      end

      def to_s
        "獣医 #{@name}"
      end
    end
  end
end
