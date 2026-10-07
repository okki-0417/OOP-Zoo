# frozen_string_literal: true

module Zoo
  module Domain
    class Assignment < ApplicationRecord
      belongs_to :keeper
      belongs_to :enclosure
    end
  end
end
