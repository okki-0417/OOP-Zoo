# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      # エンティティの等価性を id で定める mixin。
      #
      # エンティティは属性が変わっても「同じ個体」。永続化からの復元で別オブジェクトに
      # なっても、id が同じなら等価とみなす。これにより occupants の照合(include?/delete)が
      # オブジェクト同一性に依存せず、in-memory でも SQLite でも同じく機能する。
      module Entity
        def ==(other)
          other.is_a?(self.class) && id == other.id
        end
        alias eql? ==

        def hash
          [self.class, id].hash
        end
      end
    end
  end
end
