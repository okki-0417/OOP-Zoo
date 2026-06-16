# frozen_string_literal: true

require 'fileutils'

module Zoo
  module Infrastructure
    module Persistence
      module Snapshot
        module_function

        def dump(state, path)
          ::FileUtils.mkdir_p(::File.dirname(path))
          ::File.binwrite(path, Marshal.dump(state))
        end

        def load(path)
          Marshal.load(::File.binread(path))
        end

        def exist?(path)
          ::File.exist?(path)
        end
      end
    end
  end
end
