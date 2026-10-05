# frozen_string_literal: true

require 'sinatra/base'
require 'json'

module Zoo
  module Presentation
    class Web < Sinatra::Base
      set :container, nil
      set :raise_errors, false
      set :show_exceptions, false
      set :host_authorization, { permitted_hosts: [] }

      before do
        headers 'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => 'POST, OPTIONS',
                'Access-Control-Allow-Headers' => 'Content-Type'
      end

      options('*') { 200 }

      post('/graphql') do
        content_type :json
        Graphql::Schema.execute(
          payload['query'],
          variables: payload['variables'] || {},
          operation_name: payload['operationName'],
          context: { container: }
        ).to_h.to_json
      end

      private

      def container
        settings.container ||= Zoo::Composition::Container.new
      end

      def payload
        @payload ||= JSON.parse(request.body.read)
      end
    end
  end
end
