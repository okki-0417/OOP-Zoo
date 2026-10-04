module Api
  module V1
    class EnclosuresController < ApplicationController
      def index
        render json: Enclosure.all.map(&:summary_json)
      end

      def show
        render json: Enclosure.find(params[:id])
      end

      def create
        enclosure = Enclosure.build(
          name: params.require(:name),
          temperature: Temperature.celsius(Integer(params.require(:celsius))),
          capacity: Integer(params.require(:capacity))
        )
        render json: enclosure, status: :created
      end
    end
  end
end
