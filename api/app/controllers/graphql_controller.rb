# frozen_string_literal: true

class GraphqlController < ApplicationController
  wrap_parameters false

  def execute
    session = current_session
    return render json: unauthenticated, status: :unauthorized unless session

    result = OopZooSchema.execute(
      params[:query],
      variables: params[:variables]&.to_unsafe_h || {},
      operation_name: params[:operationName],
      context: { current_zoo: Zoo.of(session.user) }
    )
    render json: result
  end

  private

  def unauthenticated
    { errors: [{ message: 'ログインしていません', extensions: { code: 'Unauthenticated' } }] }
  end
end
