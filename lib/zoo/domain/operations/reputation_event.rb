# frozen_string_literal: true

module Zoo
  module Domain
    module Operations
      # 評判を動かす「ニュース(信頼チャネルの出来事)」。
      #
      # 各出来事は自分が持つデータ(死因・カリスマ性・保全価値)から、評判への効き(reputation_delta)を
      # 自分で決める。露出によらず効く=来ていない公衆にも届く、がニュースの本質。
      # 新しいニュース種は、このモジュールにクラスを1つ足すだけでよい(ReputationPolicy は不変)。
      module ReputationEvent
        # 死: 死因(帰責性)とカリスマ性(格)で評判への重みが決まる。
        class Death
          BASE_PENALTY = 5
          PREVENTABLE_MULTIPLIER = 2
          CHARISMA_PIVOT = 50
          # 飼育側の落ち度に帰せる死(=予防可能)。老衰・事故死より重い。
          PREVENTABLE_CAUSES = %i[starvation neglect].freeze

          def initialize(cause:, charisma:)
            @cause = cause
            @charisma = charisma
          end

          def reputation_delta
            weight = PREVENTABLE_CAUSES.include?(@cause) ? PREVENTABLE_MULTIPLIER : 1
            -(BASE_PENALTY * weight * @charisma / CHARISMA_PIVOT.to_f).round
          end
        end

        # 疫病の発生: それ自体が園の管理不全のニュース。
        class Outbreak
          PENALTY = 8

          def reputation_delta
            -PENALTY
          end
        end

        # 保全実績: 絶滅危惧(threatened)種の繁殖成功のみ評判を上げる。
        # 普通種のありふれた誕生は話題(buzz=魅力)止まりで評判は上げない(見たい≠信頼)。
        class ConservationBreeding
          REPUTATION_GAIN = 4

          # 絶滅危惧でない種の繁殖はニュース(信頼チャネル)にならない → nil。
          def self.for(species)
            return nil unless species.conservation_status.threatened?

            new(species)
          end

          def initialize(species)
            @species = species
          end

          def reputation_delta
            REPUTATION_GAIN
          end
        end
      end
    end
  end
end
