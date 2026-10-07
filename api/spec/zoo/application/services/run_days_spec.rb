# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::RunDays do
  catalog = Zoo::Domain::SpeciesCatalog

  let!(:zoo) { create_zoo(funds: 100_000, admission_fee: 2_000) }
  let!(:enclosure) { create_enclosure }
  let(:no_outbreak) { instance_double(Random, rand: 99) }
  let(:service) do
    described_class.new(command: Zoo::Application::Commands::RunDaysCommand.new(days: 3, random: no_outbreak))
  end

  before do
    build_adult(catalog.lion, name: '若').move_to(enclosure).save!
    build_animal(catalog.lion, name: '老', age_in_days: 1_000_000).move_to(enclosure).save!
  end

  describe '#call' do
    it 'days=3 で進めると result.value が days=3 になり、寿命超過個体の老衰死を集計すること' do
      expect(service.call.value).to eq(days: 3, total_deaths: 1, deaths_by_cause: { old_age: 1 })
    end

    it 'days=3 で進めると /operate と同じ1日の運営が3回行われ、園の経過日数が3進み運営記録が3件残ること' do
      expect { service.call }.to change { zoo.reload.day }.by(3)
      expect(Zoo::Domain::Operating.order(:day).map(&:day)).to eq([1, 2, 3])
    end

    it 'days=3 で進めると、園の収益の増分が3日分の運営記録の収入合計と一致すること' do
      before = zoo.revenue.yen
      service.call

      incomes = Zoo::Domain::Operating.all.map { |operating| operating.income.yen }
      expect(zoo.reload.revenue.yen - before).to eq(incomes.sum)
      expect(incomes).to all(be_positive)
    end
  end
end
