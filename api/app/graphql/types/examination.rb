# frozen_string_literal: true

module Types
  class Examination < BaseObject
    field :animal, Animal, null: false
    field :diagnosis, Diagnosis, null: false
  end
end
