$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'zoo'

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.default_formatter = 'doc'
end
