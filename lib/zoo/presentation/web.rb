# frozen_string_literal: true

require 'sinatra/base'
require 'json'
require 'logger'

module Zoo
  module Presentation
    class Web < Sinatra::Base
      set :container, nil
      set :operation_logger, Logger.new($stdout, formatter: ->(_, _, _, message) { "#{message}\n" })
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
        started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
        result = Graphql::Schema.execute(
          payload['query'],
          variables:,
          operation_name: payload['operationName'],
          context: { container: }
        )
        log(result, started)
        result.to_h.to_json
      end

      private

      def container
        settings.container ||= Zoo::Composition::Container.new
      end

      def payload
        @payload ||= JSON.parse(request.body.read)
      end

      def variables
        payload['variables'] || {}
      end

      def log(result, started)
        operation = result.query.selected_operation
        elapsed = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
        errors = result['errors']&.map { |error| error.dig('extensions', 'code') || error['message'] }

        settings.operation_logger.info(<<~LOG.chomp)
          Processing #{operation&.operation_type || 'unknown'} #{operation&.name || '(anonymous)'}
            Variables: #{variables.to_json}
            Query: #{payload['query'].to_s.gsub(/\s+/, ' ').strip}
          Completed in #{elapsed}ms#{" (errors: #{errors.join(', ')})" if errors}
        LOG
      end
    end
  end
end
