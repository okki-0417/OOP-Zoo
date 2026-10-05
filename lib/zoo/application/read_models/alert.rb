# frozen_string_literal: true

module Zoo
  module Application
    module ReadModels
      Alert = Data.define(:severity, :kind, :subject_type, :subject_id, :subject_name, :message) do
        const_set(:SEVERITIES, %i[critical warning notice].freeze)

        def self.about_animal(animal, severity:, kind:, message:)
          new(severity:, kind:, subject_type: :animal, subject_id: animal.id.to_s, subject_name: animal.name, message:)
        end

        def self.about_enclosure(enclosure, severity:, kind:, message:)
          new(
            severity:, kind:, subject_type: :enclosure,
            subject_id: enclosure.id.to_s, subject_name: enclosure.name, message:
          )
        end

        def self.about_zoo(zoo, severity:, kind:, message:)
          new(severity:, kind:, subject_type: :zoo, subject_id: nil, subject_name: zoo.name, message:)
        end

        def rank
          [self.class::SEVERITIES.index(severity), subject_type == :zoo ? 0 : 1, subject_name.to_s]
        end
      end
    end
  end
end
