# frozen_string_literal: true

module Zoo
  module Domain
    module BreedingPolicy
      module_function

      def can_mate?(a, b)
        rejection_reason(a, b).nil?
      end

      def related?(a, b)
        a.parent_of?(b) || b.parent_of?(a) || a.sibling_of?(b)
      end

      def rejection_reason(a, b)
        return '同種・異性・成熟・健康な個体同士でなければ繁殖できません' unless a.can_breed_with?(b)
        return '近親交配は避ける必要があります' if related?(a, b)

        nil
      end
    end
  end
end
