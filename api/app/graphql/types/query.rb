# frozen_string_literal: true

module Types
  class Query < BaseObject
    field :animals, [Animal], null: false
    field :animal, Animal do
      argument :id, ID
    end
    field :enclosures, [Enclosure], null: false
    field :enclosure, Enclosure do
      argument :id, ID
    end
    field :keepers, [Keeper], null: false
    field :veterinarians, [Veterinarian], null: false
    field :zoo, Zoo, null: false
    field :operatings, [Operating], null: false
    field :alerts, [Alert], null: false
    field :species, [Species], null: false
    field :foods, [Food], null: false
    field :taxon_classes, [TaxonClass], null: false

    def animals
      current_zoo.animals.order(:id)
    end

    def animal(id:)
      current_zoo.animals.find_by(id:)
    end

    def enclosures
      current_zoo.enclosures.order(:id)
    end

    def enclosure(id:)
      current_zoo.enclosures.find_by(id:)
    end

    def keepers
      current_zoo.keepers.order(:id)
    end

    def veterinarians
      current_zoo.veterinarians.order(:id)
    end

    def zoo
      current_zoo
    end

    def operatings
      current_zoo.operatings.order(:day, :id)
    end

    def alerts
      ::Alert.of(current_zoo)
    end

    def species
      ::SpeciesCatalog.all
    end

    def foods
      ::FoodCatalog.all
    end

    def taxon_classes
      ::TaxonClass::CLASSES.keys.map { |key| ::TaxonClass.new(key) }
    end

    private

    def current_zoo
      context[:current_zoo]
    end
  end
end
