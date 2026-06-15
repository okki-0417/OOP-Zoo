# frozen_string_literal: true

module Zoo
  module Domain
    # ドメイン規則の違反を表す例外群。
    #
    # 引数の形式エラー(ArgumentError)とは区別し、「動物園の運営ルールに反する操作」
    # を呼び出し側が捕捉して扱えるようにする。
    module Errors
      # 全ドメイン例外の基底。
      class DomainError < StandardError; end

      # 収容数の超過。
      class CapacityExceeded < DomainError; end

      # 気候(適温域)の不適合。
      class ClimateMismatch < DomainError; end

      # 同居の相性違反(捕食関係・単独性など)。
      class IncompatibleCohabitation < DomainError; end

      # 死亡個体に対する不正な操作。
      class DeadAnimal < DomainError; end

      # 食性に合わない給餌。
      class IncompatibleFood < DomainError; end

      # 繁殖が成立しない組み合わせ。
      class BreedingNotAllowed < DomainError; end

      # 担当・資格の不足(専門外の種への対応など)。
      class NotQualified < DomainError; end

      # ワクチンの無い病気への予防接種。
      class VaccineUnavailable < DomainError; end

      # 残高が費用に満たず、裁量的な購入ができない。
      class InsufficientFunds < DomainError; end
    end
  end
end
