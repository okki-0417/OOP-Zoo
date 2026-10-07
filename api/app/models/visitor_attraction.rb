# frozen_string_literal: true

class VisitorAttraction
  WILLINGNESS_BASE_YEN = 3_000
  WILLINGNESS_PER_SPECTACLE_YEN = 15

  def initialize(on_exhibit:, zoo:)
    @on_exhibit = on_exhibit
    @zoo = zoo
    @spectacle = Spectacle.new(on_exhibit: on_exhibit, buzz: zoo.buzz)
  end

  def expected_visitors
    return 0 if @on_exhibit.empty?

    spectacle = @spectacle.value
    q_max = spectacle * @zoo.reputation_factor
    p_max = WILLINGNESS_BASE_YEN + (spectacle * WILLINGNESS_PER_SPECTACLE_YEN * @zoo.reputation_factor)
    price = @zoo.admission_fee.yen
    return 0 if price >= p_max

    (q_max * (1.0 - (price.to_f / p_max))).to_i
  end
end
