# frozen_string_literal: true

module Zoo
  module Domain
    module Husbandry
      # 同一飼育エリアに2種(2個体)を同居させてよいかを判断するドメインサービス。
      #
      # 「種の本来の性質(捕食性・単独性・気候適性)」という事実から運営ルールを導く。
      # サイズだけで捕食関係を表すと現実(ライオン<シマウマでも捕食する)と矛盾するため、
      # 捕食性の有無で安全側に倒し、肉食・魚食の種は異種と同居させない方針を採る。
      module CohabitationPolicy
        module_function

        # 同居可能か。
        def compatible?(resident_species, newcomer_species)
          incompatibility_reason(resident_species, newcomer_species).nil?
        end

        # 不可能な場合の理由(可能ならnil)。
        def incompatibility_reason(resident, newcomer)
          unless resident.climate_overlaps?(newcomer)
            return "#{resident.name_ja}と#{newcomer.name_ja}は適温域が両立しません"
          end

          if resident.same_species?(newcomer)
            return "#{resident.name_ja}は単独性のため同種を同居させられません" if resident.solitary?

            return nil
          end

          if resident.predatory? || newcomer.predatory?
            return "#{resident.name_ja}と#{newcomer.name_ja}は捕食関係の恐れがあり同居させられません"
          end

          nil
        end
      end
    end
  end
end
