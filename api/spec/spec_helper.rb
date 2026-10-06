# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    enable_coverage :branch
    add_filter '/spec/'
    track_files 'lib/**/*.rb'
  end
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'zoo'

Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

RSpec.configure do |config|
  config.default_formatter = 'doc'
end
