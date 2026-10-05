# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      ChoreItem = Data.define(:subject_type, :subject_id, :subject_name, :done) do
        def self.about_animal(animal, done:)
          new(subject_type: :animal, subject_id: animal.id.to_s, subject_name: animal.name, done:)
        end

        def self.about_enclosure(enclosure, done:)
          new(subject_type: :enclosure, subject_id: enclosure.id.to_s, subject_name: enclosure.name, done:)
        end
      end
    end
  end
end
