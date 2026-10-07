# frozen_string_literal: true

class Animal
  class Sex
    include ValueObject

    VALUES = { male: 'オス', female: 'メス' }.freeze

    attr_reader :value

    def self.male
      new(:male)
    end

    def self.female
      new(:female)
    end

    def self.random
      new(VALUES.keys.sample)
    end

    def initialize(value)
      symbol = value.to_sym
      raise Errors::InvalidValue, "未知の性別です: #{value}" unless VALUES.key?(symbol)

      @value = symbol
      freeze
    end

    def male?
      @value == :male
    end

    def female?
      @value == :female
    end

    def label
      VALUES.fetch(@value)
    end

    def to_s
      label
    end

    protected

    def components
      [@value]
    end
  end
end
