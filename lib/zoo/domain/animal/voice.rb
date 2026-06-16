# frozen_string_literal: true

module Zoo
  module Domain
    class Animal
      class Voice
        include Shared::ValueObject

        attr_reader :value

        def self.silent
          new('')
        end

        def self.from(value)
          value.nil? ? silent : new(value)
        end

        def initialize(value)
          raise ArgumentError, '鳴き声はnilにできません' if value.nil?

          @value = value.to_s
          freeze
        end

        def silent?
          @value.empty?
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
