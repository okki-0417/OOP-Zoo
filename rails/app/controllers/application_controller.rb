class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Errors::DomainError, with: :render_domain_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error
  rescue_from ArgumentError, with: :render_bad_request
  rescue_from ActionController::ParameterMissing, with: :render_bad_request

  private

  def render_not_found(error)
    render_error(error, status: :not_found)
  end

  def render_domain_error(error)
    render_error(error, status: :unprocessable_entity)
  end

  def render_validation_error(error)
    render_error(error, status: :unprocessable_entity)
  end

  def render_bad_request(error)
    render_error(error, status: :bad_request)
  end

  def render_error(error, status:)
    render json: { error: { code: error.class.name.split('::').last, message: error.message } }, status: status
  end
end
