# frozen_string_literal: true

require 'fileutils'

module Zoo
  module Infrastructure
    module Persistence
      # 動物園の全状態を1ファイルに保存/復元する。1回の Marshal で dump するため、
      # エリアの occupants と AnimalRepository が同じ個体オブジェクトを共有している
      # 関係(同一性)が、復元後も保たれる。
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
