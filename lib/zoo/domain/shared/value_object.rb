# frozen_string_literal: true

module Zoo
  module Domain
    module Shared
      # 値オブジェクトの共通振る舞いを提供するmixin。
      #
      # 値オブジェクトは「同一性(identity)」ではなく「属性の値」によって等価性が決まる。
      # 各値オブジェクトは #components で等価性を構成する属性の配列を返すこと。
      # これにより == / eql? / hash がまとめて定義され、ハッシュのキーや
      # Set の要素としても安全に扱えるようになる。
      module ValueObject
        def ==(other)
          other.is_a?(self.class) && components == other.components
        end
        alias eql? ==

        def hash
          [self.class, *components].hash
        end

        # 値オブジェクトは不変であるべきなので freeze を促す。
        def freeze
          components.each { |c| c.freeze if c.respond_to?(:freeze) }
          super
        end

        protected

        # 等価性を構成する属性を配列で返す。各値オブジェクトで実装する。
        def components
          raise NotImplementedError, "#{self.class}は#componentsを実装する必要があります"
        end
      end
    end
  end
end
