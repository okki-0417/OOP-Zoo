# frozen_string_literal: true

require 'securerandom'

module Zoo
  module Domain
    module Shared
      class Identifier
        include ValueObject

        attr_reader :value

        def initialize(value = SecureRandom.uuid)
          raise ArgumentError, '識別子は空にできません' if value.to_s.empty?

          @value = value.to_s
          freeze
        end

        def to_s
          @value
        end

        protected

        def components
          [@value]
        end
      end
    end
  end
end
