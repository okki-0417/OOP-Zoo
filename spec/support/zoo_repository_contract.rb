# frozen_string_literal: true

# ZooRepository ポートが満たすべき契約。in-memory と SQLite の両実装で共有し、
# 「同じ口は同じ振る舞い」を保証する(fake と本物のドリフト防止)。
# ホスト側で let(:repository) を提供すること。
RSpec.shared_examples 'a zoo repository' do
  money = Zoo::Domain::Shared::Money

  it '未保存なら既定の動物園を load すること' do
    expect(repository.load.admission_fee).to eq(money.yen(2_000))
  end

  it 'save した状態(収益・残高・来園者数・経過日数)を load で復元できること' do
    zoo = repository.load
    zoo.admit_visitors(10) # 収益 2000*10=20,000
    3.times { zoo.advance_day }

    repository.save(zoo)
    restored = repository.load

    expect(restored.revenue).to eq(money.yen(20_000))
    expect(restored.balance).to eq(zoo.balance)
    expect(restored.visitor_count).to eq(10)
    expect(restored.day).to eq(3)
  end
end
