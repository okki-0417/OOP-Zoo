# frozen_string_literal: true

module Zoo
  module Domain
    # 動物園そのものを表す集約ルート。
    #
    # 飼育エリア・職員・収益・来園者を束ね、日々の運営(開園・加齢・収益)を司る。
    # 個々のエリアや動物の不変条件はそれぞれの集約に委ね、本集約は園全体の
    # 横断的な問い合わせ(全頭数・展示種・保全貢献)と日次処理を担う。
    class Zoo
      include Events::Recorder

      attr_reader :name, :admission_fee, :revenue, :visitor_count, :balance, :reputation

      def initialize(name:, admission_fee:, funds: Shared::Money.zero, reputation: Operations::Reputation.default)
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
      end

      # --- 構成 ---

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

      # --- 収容 ---

      # 動物をエリアに収容する。エリアは本園のものでなければならない。
      def house(animal, enclosure)
        unless @enclosures.include?(enclosure)
          raise ArgumentError, "#{enclosure.name}はこの動物園のエリアではありません"
        end

        enclosure.admit(animal)
        animal
      end

      # --- 横断的な問い合わせ ---

      # 在園する全個体。
      def animals
        @enclosures.flat_map(&:occupants)
      end

      def population
        animals.size
      end

      # 展示中の種(重複なし)。
      def species_on_exhibit
        animals.map(&:species).uniq
      end

      # 保全に貢献している絶滅危惧種。
      def threatened_species
        species_on_exhibit.select { |s| s.conservation_status.threatened? }
      end

      # これまでに死亡した個体(慰霊記録)。
      def deceased
        @deceased.dup
      end

      # --- 運営 ---

      # 来園者を受け入れ、入園料ぶんの収益を計上する。
      def admit_visitors(count)
        raise ArgumentError, '来園者数は0以上でなければなりません' if count.negative?

        @visitor_count += count
        earned = @admission_fee * count
        @revenue += earned
        @balance += earned
        @revenue
      end

      # 運営費などを支出する。残高は赤字(債務)になりうる。
      def spend(money)
        @balance -= money
        @balance
      end

      # 残高が赤字か(破産状態か)。
      def bankrupt?
        @balance.negative?
      end

      # 評判を更新する(運営結果に応じて)。
      def apply_reputation(reputation)
        @reputation = reputation
        self
      end

      # 開園して1日を過ごす。全エリアで時間が経過し、死亡個体を記録・回収し、
      # 発生したドメインイベントを園のイベントとして集約する。死亡個体一覧を返す。
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
