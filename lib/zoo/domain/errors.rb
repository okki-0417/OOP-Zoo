# frozen_string_literal: true

module Zoo
  module Domain
    module Errors
      class DomainError < StandardError; end
      class CapacityExceeded < DomainError; end
      class ClimateMismatch < DomainError; end
      class IncompatibleCohabitation < DomainError; end
      class DeadAnimal < DomainError; end
      class BreedingNotAllowed < DomainError; end
      class HousingNotAllowed < DomainError; end
      class FeedingNotAllowed < DomainError; end
      class TendingNotAllowed < DomainError; end
      class VaccineUnavailable < DomainError; end
      class InsufficientFunds < DomainError; end
    end
  end
end
