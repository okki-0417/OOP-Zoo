# frozen_string_literal: true

FactoryBot.define do
  factory :keeper do
    zoo
    sequence(:name) { |n| "飼育員#{n}" }

    transient do
      taxon_classes { [TaxonClass.mammal] }
    end

    specialties { taxon_classes.map { |taxon_class| Keeper::Specialty.new(taxon_class:) } }
  end
end
