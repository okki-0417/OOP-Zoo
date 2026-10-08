# frozen_string_literal: true

class SessionsController < ApplicationController
  def destroy
    terminate_session
    head :no_content
  end
end
