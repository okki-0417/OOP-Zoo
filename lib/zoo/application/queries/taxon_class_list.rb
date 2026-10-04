# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class TaxonClassList
        def initialize(command:)
          @command = command
        end

        def call
          Result.capture(:taxon_class_list) do
            Domain::TaxonClass::CLASSES.keys.map { |key| Domain::TaxonClass.new(key) }
          end
        end
      end
    end
  end
end
