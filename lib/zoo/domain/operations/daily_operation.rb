# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 動物園の「1日のサイクル」を回すプロセス型ドメインサービス。
      #
      # 来園→収入→運営費→疫病→評判→日送り、という1日の出来事の編成そのものをドメインに置く。
      # 状態変更は各集約のメソッド(zoo.admit_visitors/spend/apply_reputation/advance_day,
      # animal.fall_ill)経由でのみ行い、自身はリポジトリや永続化に一切触れない(純粋・I/Oなし)。
      # 加齢・死亡(dead)は先に済ませたものを受け取る。乱数は決定性のために注入する。
      module DailyOperation
        module_function

        # zoo・enclosures・animals は読み込み済みのドメインオブジェクト。dead はその日の死亡個体。
        def run(zoo:, enclosures:, animals:, dead:, staff_count:, random:)
          on_exhibit = enclosures.flat_map(&:occupants)

          visitors = VisitorAttraction.expected_visitors(
            on_exhibit, zoo.reputation, zoo.admission_fee, buzz: zoo.buzz
          )
          income = zoo.admission_fee * visitors
          zoo.admit_visitors(visitors)

          cost = OperatingCost.daily(
            enclosures: enclosures, staff: staff_count, species: animals.map(&:species)
          )
          zoo.spend(cost)

          afflicted = OutbreakPolicy.strike(on_exhibit, random)
          afflicted&.fall_ill(Medical::IllnessCatalog.parasite)

          condition = Husbandry::Condition.score(on_exhibit)
          experience = VisitorExperience.score(condition: condition, fee: zoo.admission_fee)
          zoo.apply_reputation(
            ReputationPolicy.after_day(
              zoo.reputation, experience: experience, exposure: visitors, events: news_of(dead, afflicted)
            )
          )
          zoo.advance_day

          DayOutcome.new(visitors: visitors, income: income, cost: cost, deaths: dead.size, afflicted: afflicted)
        end

        # その日のニュース(評判を動かす出来事)を組み立てる。
        # 死因は未モデル化のため :unknown(死因別の重みは ReputationEvent::Death 側に実装済み)。
        def news_of(dead, afflicted)
          events = dead.map { |a| ReputationEvent::Death.new(cause: :unknown, charisma: a.species.charisma) }
          events << ReputationEvent::Outbreak.new if afflicted
          events
        end
      end
    end
  end
end
