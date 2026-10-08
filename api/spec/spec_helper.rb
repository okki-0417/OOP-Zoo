# frozen_string_literal: true

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    enable_coverage :branch
    skip '/spec/'
    cover '{app,lib}/**/*.rb'
  end
end

RSpec.configure do |config|
  config.default_formatter = 'doc'
end
