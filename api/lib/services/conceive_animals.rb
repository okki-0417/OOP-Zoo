# frozen_string_literal: true

module Services
  class ConceiveAnimals
    def initialize(command:)
      @command = command
    end

    def call
      Result.capture(:conceive_animals) do
        ApplicationRecord.transaction do
          sire = ::Animal.find_by(id: @command.sire_id)
          raise Errors::AnimalNotFound, "動物 #{@command.sire_id} は存在しません" if sire.nil?

          dam = ::Animal.find_by(id: @command.dam_id)
          raise Errors::AnimalNotFound, "動物 #{@command.dam_id} は存在しません" if dam.nil?

          zoo = ::Zoo.current

          breeding = ::Breeding.new(sire:, dam:, day: zoo.day, season: zoo.season)
          breeding.conceive

          dam.save!
          breeding.save!
        end
        nil
      end
    end
  end
end
