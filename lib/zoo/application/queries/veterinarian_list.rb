# frozen_string_literal: true

module Zoo
  module Application
    module Queries
      class VeterinarianList
        def initialize(veterinarians:)
          @veterinarians = veterinarians
        end

        def call
          @veterinarians.all.map do |vet|
            ReadModels::VeterinarianSummary.new(id: vet.id.to_s, name: vet.name)
          end
        end
      end
    end
  end
end
