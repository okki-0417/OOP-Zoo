# frozen_string_literal: true

require 'zeitwerk'

module Zoo
  loader = Zeitwerk::Loader.for_gem
  loader.setup
end
