# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      class InMemorySpeciesRepository
        include Domain::Repositories::SpeciesRepository

        def find(code)
          Domain::SpeciesCatalog.find(code)
        end

        def all_by_code
          Domain::SpeciesCatalog.keys.to_h { |code| [code, Domain::SpeciesCatalog.find(code)] }
        end
      end
    end
  end
end
