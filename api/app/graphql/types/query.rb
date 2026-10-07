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
      ::Animal.order(:id)
    end

    def animal(id:)
      ::Animal.find_by(id:)
    end

    def enclosures
      ::Enclosure.order(:id)
    end

    def enclosure(id:)
      ::Enclosure.find_by(id:)
    end

    def keepers
      ::Keeper.order(:id)
    end

    def veterinarians
      ::Veterinarian.order(:id)
    end

    def zoo
      ::Zoo.current
    end

    def operatings
      ::Operating.order(:day, :id)
    end

    def alerts
      Services::AlertList.new(command: Services::Commands::AlertListCommand.new).call.value
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
  end
end
