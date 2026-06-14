# frozen_string_literal: true

module Zoo
  module Presentation
    class Cli
      class Animal < Command
        CAUSE_LABELS = { old_age: '老衰', starvation: '餓死', illness: '病死', predation: '捕食', unknown: '不明' }.freeze

        def run(args)
          animal_id, = args
          raise ArgumentError, '使い方: animal ANIMAL_ID' if animal_id.nil?

          profile = @container.animal_detail.call(animal_id)
          raise Application::Errors::AnimalNotFound, "動物 #{animal_id} は存在しません" if profile.nil?

          print_profile(profile)
        end

        private

        def print_profile(profile)
          @output.puts "#{profile.name}（#{profile.species} / #{profile.taxon_class} / #{profile.diet}）"
          @output.puts "  id: #{profile.id}"
          @output.puts "  性別: #{profile.sex}  ライフステージ: #{profile.life_stage}（#{profile.age_in_days}日齢）"
          @output.puts "  体力: #{profile.health}/#{profile.max_health}#{profile.weak ? ' ⚠衰弱' : ''}"
          @output.puts "  空腹度: #{profile.hunger}#{profile.starving ? ' ⚠飢餓' : ''}"
          @output.puts "  保全状況: #{profile.conservation_code}（#{profile.conservation_label}）"
          @output.puts "  病気: #{profile.illness || 'なし'}"
          @output.puts "  状態: #{status_text(profile)}"
          @output.puts "  両親: #{profile.parents}頭"
        end

        def status_text(profile)
          return '生存' if profile.alive

          "死亡（#{CAUSE_LABELS.fetch(profile.cause, profile.cause)}）"
        end
      end
    end
  end
end
