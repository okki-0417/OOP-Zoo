# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Death
        include Shared::ValueObject

        attr_reader :cause

        def initialize(cause: :unknown)
          @cause = cause
          freeze
        end

        def to_s
          cause.to_s
        end

        protected

        def components
          [@cause]
        end
      end
    end
  end
end
