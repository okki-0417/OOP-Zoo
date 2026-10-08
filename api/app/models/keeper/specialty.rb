# frozen_string_literal: true

class Keeper
  class Specialty < ApplicationRecord
    belongs_to :keeper

    attribute :taxon_class, ValueType.new(TaxonClass, dump: ->(taxon_class) { taxon_class.value.to_s })
  end
end
