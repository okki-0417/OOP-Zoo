# frozen_string_literal: true

class GraphqlController < ApplicationController
  wrap_parameters false

  def execute
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    result = OopZooSchema.execute(
      params[:query],
      variables:,
      operation_name: params[:operationName]
    )
    log(result, started)
    render json: result
  end

  private

  def variables
    params[:variables]&.to_unsafe_h || {}
  end

  def log(result, started)
    operation = result.query.selected_operation
    elapsed = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000).round
    errors = result['errors']&.map { |error| error.dig('extensions', 'code') || error['message'] }

    Rails.logger.info(<<~LOG.chomp)
      GraphQL #{operation&.operation_type || 'unknown'} #{operation&.name || '(anonymous)'}
        Variables: #{variables.to_json}
        Query: #{params[:query].to_s.gsub(/\s+/, ' ').strip}
      Completed in #{elapsed}ms#{" (errors: #{errors.join(', ')})" if errors}
    LOG
  end
end
