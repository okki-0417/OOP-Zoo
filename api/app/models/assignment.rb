# frozen_string_literal: true

class Assignment < ApplicationRecord
  belongs_to :keeper
  belongs_to :enclosure
end
