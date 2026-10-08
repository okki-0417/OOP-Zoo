# frozen_string_literal: true

module Dev
  class SessionsController < ApplicationController
    def create
      start_new_session_for(User.first_or_create!)
      head :no_content
    end
  end
end
