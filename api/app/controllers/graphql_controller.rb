# frozen_string_literal: true

class GraphqlController < ApplicationController
  wrap_parameters false

  def execute
    result = OopZooSchema.execute(
      params[:query],
      variables: params[:variables]&.to_unsafe_h || {},
      operation_name: params[:operationName]
    )
    render json: result
  end
end
