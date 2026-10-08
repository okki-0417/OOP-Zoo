# frozen_string_literal: true

module Mutations
  class HireKeeper < BaseMutation
    type Types::Keeper, null: false

    argument :name, String
    argument :specialties, [String]

    def resolve(name:, specialties:)
      keeper = Keeper.new(name:, specialties: specialties.map { |key| TaxonClass.new(key) })
      Hiring.new(zoo: current_zoo, employee: keeper).perform
    end
  end
end
