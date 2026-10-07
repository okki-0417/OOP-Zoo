# frozen_string_literal: true

module Zoo
  module Presentation
    module Graphql
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
            Domain::Animal.order(:id)
          end

          def animal(id:)
            Domain::Animal.find_by(id:)
          end

          def enclosures
            Domain::Enclosure.order(:id)
          end

          def enclosure(id:)
            Domain::Enclosure.find_by(id:)
          end

          def keepers
            Domain::Keeper.order(:id)
          end

          def veterinarians
            Domain::Veterinarian.order(:id)
          end

          def zoo
            Domain::Zoo.current
          end

          def operatings
            Domain::Operating.order(:day, :id)
          end

          def alerts
            Application::Services::AlertList.new(command: Application::Commands::AlertListCommand.new).call.value
          end

          def species
            Domain::SpeciesCatalog.all
          end

          def foods
            Domain::FoodCatalog.all
          end

          def taxon_classes
            Domain::TaxonClass::CLASSES.keys.map { |key| Domain::TaxonClass.new(key) }
          end
        end
      end
    end
  end
end
