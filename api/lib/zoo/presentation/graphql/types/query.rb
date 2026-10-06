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
            container.animals.all
          end

          def animal(id:)
            container.animals.find(id)
          end

          def enclosures
            container.enclosures.all
          end

          def enclosure(id:)
            container.enclosures.find(id)
          end

          def keepers
            container.keepers.all
          end

          def veterinarians
            container.veterinarians.all
          end

          def zoo
            container.zoo.load
          end

          def operatings
            container.operatings.all
          end

          def alerts
            container.alert_list(Application::Commands::AlertListCommand.new).value
          end

          def species
            container.species.all_by_code.values
          end

          def foods
            container.foods.all_by_code.values
          end

          def taxon_classes
            Domain::TaxonClass::CLASSES.keys.map { |key| Domain::TaxonClass.new(key) }
          end
        end
      end
    end
  end
end
