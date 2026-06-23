# frozen_string_literal: true

module Zoo
  module Domain
    class Zoo
      include Events::Recorder

      def initialize(name:, admission_fee:, funds: Shared::Money.zero, reputation: Reputation.default)
        raise ArgumentError, '動物園名は必須です' if name.to_s.empty?

        @name = name
        @admission_fee = admission_fee
        @enclosures = []
        @keepers = []
        @veterinarians = []
        @revenue = Shared::Money.zero
        @visitor_count = 0
        @deceased = []
        @balance = Shared::Balance.new(funds.yen)
        @reputation = reputation
        @day = 0
        @buzz = 0
      end

      attr_reader :name, :admission_fee, :revenue, :visitor_count, :balance, :reputation, :day, :buzz

      def reputation_factor
        @reputation.factor
      end

      def reputation_score
        @reputation.score
      end

      BUZZ_DECAY_PER_DAY = 10

      def generate_buzz(amount)
        @buzz += amount
        self
      end

      def self.reconstitute(name:, admission_fee:, revenue:, visitor_count:, balance:, reputation:, day: 0)
        new(name: name, admission_fee: admission_fee, reputation: reputation).tap do |zoo|
          zoo.instance_variable_set(:@revenue, revenue)
          zoo.instance_variable_set(:@visitor_count, visitor_count)
          zoo.instance_variable_set(:@balance, balance)
          zoo.instance_variable_set(:@day, day)
        end
      end

      def season
        Season.on_day(@day)
      end

      def advance_day
        @day += 1
        @buzz = [@buzz - BUZZ_DECAY_PER_DAY, 0].max
        self
      end

      def add_enclosure(enclosure)
        @enclosures << enclosure unless @enclosures.include?(enclosure)
        enclosure
      end

      def hire_keeper(keeper)
        @keepers << keeper unless @keepers.include?(keeper)
        keeper
      end

      def hire_veterinarian(veterinarian)
        @veterinarians << veterinarian unless @veterinarians.include?(veterinarian)
        veterinarian
      end

      def enclosures
        @enclosures.dup
      end

      def keepers
        @keepers.dup
      end

      def veterinarians
        @veterinarians.dup
      end

      def find_enclosure(name)
        @enclosures.find { |e| e.name == name }
      end

      def deceased
        @deceased.dup
      end

      def admit_visitors(count)
        raise ArgumentError, '来園者数は0以上でなければなりません' if count.negative?

        @visitor_count += count
        earned = @admission_fee * count
        @revenue += earned
        @balance += earned
        earned
      end

      def spend(money)
        @balance -= money
        @balance
      end

      def afford?(money)
        @balance.yen >= money.yen
      end

      def purchase(money)
        raise Errors::InsufficientFunds, "残高#{@balance}では#{money}を支払えません" unless afford?(money)

        @balance -= money
        @balance
      end

      def bankrupt?
        @balance.negative?
      end

      def gain_reputation(amount)
        @reputation = @reputation.gain(amount)
        self
      end

      def update_reputation(experience:, exposure:, events: [])
        @reputation = @reputation.after_day(experience: experience, exposure: exposure, events: events)
        self
      end

      def change_admission_fee(fee)
        @admission_fee = fee
        self
      end

      def to_s
        "#{@name}(#{@enclosures.size}エリア)"
      end
    end
  end
end
