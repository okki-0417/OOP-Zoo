# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AnimalPrognosis do
  catalog = Zoo::Domain::SpeciesCatalog

  let(:enclosure) do
    Zoo::Domain::Enclosure.new(name: '丘', temperature: Zoo::Domain::Shared::Temperature.celsius(25), capacity: 4)
  end

  def outlook_of(animal, housings: [])
    command = Factory::AnimalPrognosisCommand.with_bind(
      animal_id: animal.id,
      animals: Factory::AnimalRepository.build([animal]),
      housings: Factory::HousingRepository.build(housings)
    )
    described_class.new(command:).call
  end

  describe '#call' do
    it '未収容の個体は prognosis=nil を返すこと' do
      lion = build_adult(catalog.lion)
      expect(outlook_of(lion).value).to eq(animal: lion, prognosis: nil)
    end

    it '肺炎のライオンを収容していると outlook=:guarded・days_to_death=12・cause_of_death_label="病死" の Prognosis を返すこと' do
      lion = build_adult(catalog.lion, name: 'レオ')
      mate = build_adult(catalog.lion, name: 'ナラ', sex: Zoo::Domain::Animal::Sex.female)
      lion.fall_ill(Zoo::Domain::IllnessCatalog.pneumonia)

      prognosis = outlook_of(lion, housings: [housed(lion, enclosure), housed(mate, enclosure)]).value[:prognosis]

      expect(prognosis).to have_attributes(outlook: :guarded, days_to_death: 12, cause_of_death_label: '病死')
    end

    it "存在しない id 'missing' は AnimalNotFound の失敗 Result を返すこと" do
      command = Factory::AnimalPrognosisCommand.with_bind(animal_id: 'missing')
      expect(described_class.new(command:).call.error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
