# frozen_string_literal: true

class Exposure
  def initialize(visitors:)
    @visitors = visitors
  end

  def score
    @visitors
  end
end
