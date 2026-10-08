# frozen_string_literal: true

Rails.application.routes.draw do
  post 'graphql', to: 'graphql#execute'
  resource :session, only: :destroy
  if Rails.env.local?
    namespace :dev do
      resource :session, only: :create
    end
  end
  get 'up' => 'rails/health#show', as: :rails_health_check
end
