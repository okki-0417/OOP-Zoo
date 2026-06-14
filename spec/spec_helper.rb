# カバレッジ計測は COVERAGE=1 のときだけ有効にする(通常実行は素のまま)。
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

Dir[File.expand_path('support/**/*.rb', __dir__)].sort.each { |f| require f }

RSpec.configure do |config|
  config.default_formatter = 'doc'
end
