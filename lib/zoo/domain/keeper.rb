# frozen_string_literal: true

module Zoo
  module Domain
    class Keeper
      include Shared::Entity

      attr_reader :id, :name, :specialties

      SIGNING_FEE_YEN = 20_000
      DAILY_SALARY_YEN = 12_000

      def self.signing_fee
        Shared::Money.yen(SIGNING_FEE_YEN)
      end

      def salary
        Shared::Money.yen(DAILY_SALARY_YEN)
      end

      def initialize(name:, specialties:, id: Shared::Identifier.new)
        raise ArgumentError, '飼育員名は必須です' if name.to_s.empty?
        raise ArgumentError, '専門分野を1つ以上指定してください' if specialties.nil? || specialties.empty?

        @id = id
        @name = name
        @specialties = specialties
        @shift = Shift.fresh
      end

      def self.reconstitute(id:, name:, specialties:, shift: Shift.fresh)
        allocate.tap do |keeper|
          keeper.instance_variable_set(:@id, id)
          keeper.instance_variable_set(:@name, name)
          keeper.instance_variable_set(:@specialties, specialties)
          keeper.instance_variable_set(:@shift, shift)
        end
      end

      def available_for?(minutes)
        @shift.allows?(minutes)
      end

      def clock_in(minutes)
        unless available_for?(minutes)
          raise Errors::WorkNotAllowed, "飼育員#{@name}は今日の勤務時間が足りません(残り#{remaining_minutes}分)"
        end

        @shift = @shift.worked(minutes)
        self
      end

      def remaining_minutes
        @shift.remaining_minutes
      end

      def worked_minutes
        @shift.worked_minutes
      end

      def end_shift
        @shift = Shift.fresh
        self
      end

      def specialized_in?(taxon_class)
        @specialties.include?(taxon_class)
      end

      def specialties_label
        @specialties.map(&:label).join('・')
      end

      def to_s
        "飼育員 #{@name}(#{specialties_label}担当)"
      end
    end
  end
end
