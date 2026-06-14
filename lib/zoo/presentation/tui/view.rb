# frozen_string_literal: true

require 'tty-box'
require 'tty-table'
require 'pastel'

module Zoo
  module Presentation
    class Tui
      class View
        CAUSE_LABELS = { old_age: '老衰', starvation: '餓死', illness: '病死', predation: '捕食', unknown: '不明' }.freeze

        def initialize(pastel: Pastel.new)
          @pastel = pastel
        end

        def dashboard(stats, enclosures:, staff:)
          TTY::Box.frame(
            "在園 #{stats.population}頭 / #{stats.species_count}種（絶滅危惧 #{stats.threatened_count}）    " \
            "エリア #{enclosures} / 職員 #{staff}",
            "残高 #{balance_text(stats.balance)}    収益 #{stats.revenue}",
            "評判 #{reputation_bar(stats.reputation)} #{stats.reputation}/100",
            "誕生 #{stats.births}件    死亡 #{format_deaths(stats.deaths_by_cause)}",
            title: { top_left: ' OOP動物園 ダッシュボード ' }, padding: [0, 1], width: 72
          )
        end

        # 操作結果の見出し(ダッシュボードとの境界)。
        def section(label)
          @pastel.cyan.bold("\n── #{label} ───────────────────────────")
        end

        def continue_hint
          @pastel.dim('（何かキーを押すとダッシュボードに戻る）')
        end

        def animal_table(rows)
          return '個体はいません' if rows.empty?

          TTY::Table.new(
            header: %w[名前 種 状態 id],
            rows: rows.map { |r| [r.name, r.species, r.alive ? '生存' : @pastel.dim('死亡'), r.id[0, 8]] }
          ).render(:unicode, padding: [0, 1])
        end

        def enclosure_table(rows)
          return 'エリアはありません' if rows.empty?

          TTY::Table.new(
            header: %w[名前 収容 id],
            rows: rows.map { |r| [r.name, "#{r.population}/#{r.capacity}", r.id[0, 8]] }
          ).render(:unicode, padding: [0, 1])
        end

        def animal_detail(p)
          TTY::Box.frame(
            "#{p.name}（#{p.species} / #{p.taxon_class} / #{p.diet}）",
            "性別 #{p.sex}  #{p.life_stage}  #{p.age_in_days}日齢",
            "体力 #{p.health}/#{p.max_health}#{p.weak ? ' ⚠' : ''}  空腹 #{p.hunger}#{p.starving ? ' ⚠' : ''}",
            "保全 #{p.conservation_code}（#{p.conservation_label}）  病気 #{p.illness || 'なし'}",
            "状態 #{p.alive ? '生存' : '死亡'}  両親 #{p.parents}頭",
            title: { top_left: ' 個体詳細 ' }, padding: [0, 1], width: 64
          )
        end

        def report(stats)
          TTY::Box.frame(
            "在園 #{stats.population}頭 / #{stats.species_count}種 / 絶滅危惧 #{stats.threatened_count}種",
            "誕生 #{stats.births}件  死亡 #{format_deaths(stats.deaths_by_cause)}",
            "収益 #{stats.revenue}  残高 #{stats.balance}  評判 #{stats.reputation}/100",
            title: { top_left: ' レポート ' }, padding: [0, 1], width: 64
          )
        end

        def enclosure_detail(profile)
          TTY::Box.frame(
            "#{profile.name}（収容 #{profile.population}/#{profile.capacity}）",
            "清潔度 #{profile.cleanliness}/100#{profile.filthy ? @pastel.red('  ⚠不衛生') : ''}",
            "収容個体: #{profile.occupants.empty? ? 'なし' : profile.occupants.map(&:name).join('、')}",
            title: { top_left: ' エリア詳細 ' }, padding: [0, 1], width: 64
          )
        end

        def threatened_table(rows)
          return '展示中の絶滅危惧種はいません' if rows.empty?

          TTY::Table.new(
            header: %w[種 保全 頭数],
            rows: rows.map { |r| [r.name_ja, "#{r.status_code}/#{r.status_label}", r.count] }
          ).render(:unicode, padding: [0, 1])
        end

        def deceased_table(records)
          return '死亡記録はありません' if records.empty?

          TTY::Table.new(
            header: %w[名前 種 死因],
            rows: records.map { |r| [r.name, r.species, CAUSE_LABELS.fetch(r.cause, r.cause)] }
          ).render(:unicode, padding: [0, 1])
        end

        def error(message)
          @pastel.red("⚠ #{message}")
        end

        def day_report(report)
          mark = report.bankrupt ? @pastel.red('赤字！') : @pastel.green('黒字')
          lines = [
            "来園 #{report.visitors}人 / 収入 #{report.income} / 費用 #{report.cost}",
            "死亡 #{report.deaths}頭 / 評判 #{report.reputation} / 残高 #{report.balance}（#{mark}）"
          ]
          lines << @pastel.red("🦠 疫病発生: #{report.outbreak} が発病！（治療/清掃を）") if report.outbreak
          lines.join("\n")
        end

        private

        def format_deaths(deaths_by_cause)
          return '0件' if deaths_by_cause.empty?

          deaths_by_cause.map { |cause, count| "#{CAUSE_LABELS.fetch(cause, cause)}#{count}" }.join('・')
        end

        def reputation_bar(score)
          filled = score / 10
          @pastel.green('█' * filled) + @pastel.dim('░' * (10 - filled))
        end

        def balance_text(balance)
          balance.negative? ? @pastel.red("#{balance}（赤字）") : @pastel.green(balance.to_s)
        end
      end
    end
  end
end
