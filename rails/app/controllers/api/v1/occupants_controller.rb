module Api
  module V1
    class OccupantsController < ApplicationController
      def create
        enclosure = Enclosure.find(params.require(:enclosure_id))
        animal = Animal.find(params.require(:animal_id))
        Housing.house(animal: animal, enclosure: enclosure, occupancy: Occupancy.of(enclosure))
        render json: enclosure, status: :created
      end

      def destroy
        animal = Animal.find(params.require(:animal_id))
        current = Housing.current_for(animal)
        raise ActiveRecord::RecordNotFound, "収容記録が見つかりません: animal_id=#{animal.id}" unless current

        Releasing.release(housing: current)
        render json: animal
      end
    end
  end
end
