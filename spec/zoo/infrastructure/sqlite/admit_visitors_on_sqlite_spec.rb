# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'AdmitVisitors on SQLite' do
  shared = Zoo::Domain::Shared
  sqlite = Zoo::Infrastructure::Sqlite

  it '実トランザクションで来園を受け入れ、収益が永続化されること' do
    database = sqlite::Database.new
    zoo_repository = sqlite::ZooRepository.new(
      database, Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: shared::Money.yen(2_000))
    )
    service = Zoo::Application::Services::AdmitVisitors.new(
      zoo: zoo_repository, unit_of_work: sqlite::UnitOfWork.new(database)
    )

    service.call(Zoo::Application::Commands::AdmitVisitorsCommand.new(count: 5))

    expect(zoo_repository.load.revenue).to eq(shared::Money.yen(10_000))
  end
end
