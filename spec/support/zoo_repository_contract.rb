# frozen_string_literal: true

RSpec.shared_examples 'a zoo repository' do
  money = Zoo::Domain::Shared::Money

  it '未保存なら既定の動物園を load すること' do
    expect(repository.load.admission_fee).to eq(money.yen(2_000))
  end

  it 'save した状態(収益・残高・来園者数・経過日数)を load で復元できること' do
    zoo = repository.load
    zoo.admit_visitors(10)
    3.times { zoo.advance_day }

    repository.save(zoo)
    restored = repository.load

    expect(restored.revenue).to eq(money.yen(20_000))
    expect(restored.balance).to eq(zoo.balance)
    expect(restored.visitor_count).to eq(10)
    expect(restored.day).to eq(3)
  end
end
