# frozen_string_literal: true

class Animal
  class Immunity < ApplicationRecord
    belongs_to :animal

    attribute :illness, ValueType.new(
      Illness, load: IllnessCatalog.method(:find), dump: ->(illness) { IllnessCatalog.key_of(illness).to_s }
    )
  end
end
