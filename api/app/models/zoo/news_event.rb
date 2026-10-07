# frozen_string_literal: true

class Zoo
  class NewsEvent
    def initialize(animal: nil, afflicted: nil)
      @animal    = animal
      @afflicted = afflicted
    end

    def reputation_delta
      return ReputationEvent::Outbreak.new.reputation_delta if @afflicted

      ReputationEvent::Death.new(cause: @animal.cause_of_death, charisma: @animal.charisma).reputation_delta
    end
  end
end
