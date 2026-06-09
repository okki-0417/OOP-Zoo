$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'zoo'

RSpec.configure do |config|
  config.default_formatter = 'doc'
end
