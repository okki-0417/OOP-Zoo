# frozen_string_literal: true

module Services
  module Errors
    class ApplicationError < StandardError; end
    class EnclosureNotFound < ApplicationError; end
    class AnimalNotFound < ApplicationError; end
    class SpeciesNotFound < ApplicationError; end
    class FoodNotFound < ApplicationError; end
    class KeeperNotFound < ApplicationError; end
    class VeterinarianNotFound < ApplicationError; end
    class BreedingNotFound < ApplicationError; end
    class AssignmentNotFound < ApplicationError; end
  end
end
