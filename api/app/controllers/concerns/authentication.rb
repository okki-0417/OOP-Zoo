# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    include ActionController::Cookies
  end

  private

  def current_session
    Session.find_by(id: cookies.signed[:session_id])
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      cookies.signed.permanent[:session_id] = {
        value: session.id, httponly: true, same_site: :lax, secure: Rails.env.production?
      }
    end
  end

  def terminate_session
    current_session&.destroy
    cookies.delete(:session_id)
  end
end
