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

      def house(animal, enclosure)
        raise ArgumentError, "#{enclosure.name}はこの動物園のエリアではありません" unless @enclosures.include?(enclosure)

        enclosure.admit(animal)
        animal
      end

      def animals
        @enclosures.flat_map(&:occupants)
      end

      def population
        animals.size
      end

      def species_on_exhibit
        animals.map(&:species).uniq
      end

      def threatened_species
        species_on_exhibit.select { |s| s.conservation_status.threatened? }
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

      def apply_reputation(reputation)
        @reputation = reputation
        self
      end

      def change_admission_fee(fee)
        @admission_fee = fee
        self
      end

      def open_for_a_day
        dead_today = []

        @enclosures.each do |enclosure|
          enclosure.pass_day.each do |dead|
            @deceased << dead
            dead.pull_events.each { |event| record_event(event) }
            dead_today << dead
          end
        end

        dead_today
      end

      def to_s
        "#{@name}(#{@enclosures.size}エリア・#{population}頭)"
      end
    end
  end
end
