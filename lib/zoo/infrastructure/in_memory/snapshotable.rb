# frozen_string_literal: true

module Zoo
  module Infrastructure
    module InMemory
      # ロールバック用に @store の浅いスナップショットを取る。在不在(追加/削除)は
      # 巻き戻せるが、既存集約への in-place 変更は巻き戻せない。ドメインが検査→変更の
      # 順で副作用を最後に置くため、巻き戻し時に未確定の in-place 変更が残らず足りる。
      module Snapshotable
        def snapshot
          @store.dup
        end

        def restore(snapshot)
          @store = snapshot
        end
      end
    end
  end
end
