# frozen_string_literal: true

module Zoo
  module Presentation
    class Web
      class ListTaxonClasses < Action
        def call(_params)
          taxon = Domain::TaxonClass
          [200, taxon::CLASSES.keys.map { |key| Serializer.taxon_class_ref(key, taxon.new(key)) }]
        end
      end
    end
  end
end
