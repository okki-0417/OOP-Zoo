# frozen_string_literal: true

class Animal
  class Voice
    include ValueObject

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
