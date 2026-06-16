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

      attr_reader :name, :admission_fee, :revenue, :visitor_count, :balance, :reputation, :day

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
        @day = 0
        @buzz = 0
      end

      # 現在の話題度(幼獣誕生などで一時的に高まり、日々薄れる集客の押し上げ)。
      attr_reader :buzz

      # 1日あたりに薄れる話題度。
      BUZZ_DECAY_PER_DAY = 10

      # 話題を生む(幼獣誕生など)。
      def generate_buzz(amount)
        @buzz += amount
        self
      end

      # 保存済みの状態から復元する(永続化からの読み戻し用)。生成(new)の初期化規則を
      # 通さず、収益・来園者数・残高・経過日数を保存値そのままに組み直す。
      def self.reconstitute(name:, admission_fee:, revenue:, visitor_count:, balance:, reputation:, day: 0)
        new(name: name, admission_fee: admission_fee, reputation: reputation).tap do |zoo|
          zoo.instance_variable_set(:@revenue, revenue)
          zoo.instance_variable_set(:@visitor_count, visitor_count)
          zoo.instance_variable_set(:@balance, balance)
          zoo.instance_variable_set(:@day, day)
        end
      end

      # 現在の季節。経過日数から導く。
      def season
        Operations::Calendar.season_for(@day)
      end

      # 1日進める。話題は時間とともに薄れる。
      def advance_day
        @day += 1
        @buzz = [@buzz - BUZZ_DECAY_PER_DAY, 0].max
        self
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

      # 来園者を受け入れ、入園料ぶんの収益を計上する。その回の収入(料金×人数)を返す。
      def admit_visitors(count)
        raise ArgumentError, '来園者数は0以上でなければなりません' if count.negative?

        @visitor_count += count
        earned = @admission_fee * count
        @revenue += earned
        @balance += earned
        earned
      end

      # 運営費などを支出する。残高は赤字(債務)になりうる。
      def spend(money)
        @balance -= money
        @balance
      end

      # 残高でこの費用を支払えるか。
      def afford?(money)
        @balance.yen >= money.yen
      end

      # 裁量的な購入。残高が足りなければ拒否し、残高は変えない。
      def purchase(money)
        raise Errors::InsufficientFunds, "残高#{@balance}では#{money}を支払えません" unless afford?(money)

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

      # 入園料を改定する。高くすると客単価は上がるが来園者数は減る。
      def change_admission_fee(fee)
        @admission_fee = fee
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
