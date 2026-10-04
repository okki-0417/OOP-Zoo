module Api
  module V1
    class AnimalsController < ApplicationController
      def index
        render json: Animal.all.map(&:summary_json)
      end

      def show
        render json: Animal.find(params[:id])
      end

      def create
        animal = Animal.acquire(
          species_key: params.require(:species),
          name: params.require(:name),
          sex: params.require(:sex),
          max_health: Integer(params.fetch(:max_health, 100)),
          age_in_days: Integer(params.fetch(:age_in_days, 0))
        )
        render json: animal, status: :created
      end

      def name
        animal = Animal.find(params[:id])
        animal.change_name(params.require(:name))
        animal.save!
        render json: animal
      end

      def transfer
        animal = Animal.find(params[:id])
        enclosure = Enclosure.find(params.require(:enclosure_id))
        current = Housing.current_for(animal)
        Releasing.release(housing: current) if current
        Housing.house(animal: animal, enclosure: enclosure, occupancy: Occupancy.of(enclosure))
        render json: animal
      end
    end
  end
end
