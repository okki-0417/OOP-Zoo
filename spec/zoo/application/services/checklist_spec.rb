# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::Checklist do
  catalog = Zoo::Domain::SpeciesCatalog
  female  = Zoo::Domain::Animal::Sex.female

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:mate) { build_adult(catalog.lion, name: 'ナラ', sex: female) }
  let(:hill) { Zoo::Domain::Enclosure.new(name: 'ライオンの丘', temperature: Zoo::Domain::Shared::Temperature.celsius(25), capacity: 4) }

  def checklist(animals: [lion, mate], housed_in: hill, unhoused: [])
    command = Factory::ChecklistCommand.with_bind(
      animals: Factory::AnimalRepository.build(animals + unhoused),
      housings: Factory::HousingRepository.build(animals.map { |animal| housed(animal, housed_in) })
    )
    described_class.new(command:).call.value.to_h { |chore| [chore[:kind], chore] }
  end

  def progress(chore)
    [chore[:items].count { |item| item[:done] }, chore[:items].size]
  end

  describe '#call' do
    it 'feeding/treatment/cleaning/enrichment の4つの日課を、この順で返すこと' do
      expect(checklist.keys).to eq(%i[feeding treatment cleaning enrichment])
      expect(checklist.values.map { |chore| chore[:label] }).to eq(%w[給餌 治療 清掃 遊具の補充])
    end

    it '2頭のうち1頭(レオ)に take_meal すると、給餌は 1/2 で、レオだけ done=true になること' do
      lion.take_meal([:meat])
      feeding = checklist[:feeding]

      expect(progress(feeding)).to eq([1, 2])
      expect(feeding[:items].map { |item| [item[:subject].name, item[:done]] }).to contain_exactly(['レオ', true], ['ナラ', false])
    end

    it '死亡個体と未収容の個体は給餌の対象に含めないこと' do
      lion.die
      stray = build_adult(catalog.lion, name: '迷子')

      expect(checklist(unhoused: [stray])[:feeding][:items].map { |item| item[:subject].name }).to eq(['ナラ'])
    end

    it '病気の個体(未収容も含む)だけを done=false の治療の対象として返すこと' do
      lion.fall_ill(Zoo::Domain::IllnessCatalog.cold)
      stray = build_adult(catalog.lion, name: '迷子').tap { |animal| animal.fall_ill(Zoo::Domain::IllnessCatalog.cold) }

      treatment = checklist(unhoused: [stray])[:treatment]
      expect(treatment[:items].map { |item| [item[:subject].name, item[:done]] }).to contain_exactly(['レオ', false], ['迷子', false])
    end

    it '病気の個体がいなければ治療は 0/0 になること' do
      expect(progress(checklist[:treatment])).to eq([0, 0])
    end

    it '清潔度70(soil(30))のエリアは清掃が done=false、71 なら done=true になること' do
      expect(checklist(housed_in: hill.soil(30))[:cleaning][:items].map { |item| item[:done] }).to eq([false])
      expect(checklist(housed_in: hill.clean.soil(29))[:cleaning][:items].map { |item| item[:done] }).to eq([true])
    end

    it '刺激度50(deplete_enrichment(50))のエリアは遊具の補充が done=false になり、subject は enclosure であること' do
      item = checklist(housed_in: hill.deplete_enrichment(50))[:enrichment][:items].first

      expect(item).to eq(type: :enclosure, subject: hill, done: false)
    end

    it '生きた動物のいないエリアは清掃・遊具の補充の対象に含めないこと' do
      [lion, mate].each(&:die)

      expect(progress(checklist[:cleaning])).to eq([0, 0])
      expect(progress(checklist[:enrichment])).to eq([0, 0])
    end
  end
end
