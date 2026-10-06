# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ConceiveAnimals do
  shared    = Zoo::Domain::Shared
  animal    = Zoo::Domain::Animal
  catalog   = Zoo::Domain::SpeciesCatalog
  in_memory = Zoo::Infrastructure::InMemory

  let(:pair) { build_pair(catalog.lion) }
  let(:sire) { pair[0] }
  let(:dam)  { pair[1] }

  let(:animals) { in_memory::InMemoryAnimalRepository.new([sire, dam]) }
  let(:breedings) { in_memory::InMemoryBreedingRepository.new }
  let(:births) { in_memory::InMemoryBirthRepository.new }
  let(:unit_of_work) { in_memory::InMemoryUnitOfWork.new(repositories: [animals, breedings]) }
  let(:zoo) do
    in_memory::InMemoryZooRepository.new(
      Zoo::Domain::Zoo.new(name: '園', admission_fee: shared::Money.yen(2000))
    )
  end

  def conceive(sire_id: sire.id, dam_id: dam.id, animals: self.animals, zoo: self.zoo,
               breedings: self.breedings, unit_of_work: self.unit_of_work)
    command = Zoo::Application::Commands::ConceiveAnimalsCommand.new(sire_id:, dam_id:)
    described_class.new(command: command.bind(animals:, breedings:, births:, zoo:, unit_of_work:)).call
  end

  describe '#call' do
    it 'sire/dam の id を渡すと success で value が nil になり、dam が妊娠状態になること' do
      result = conceive

      expect(result.value).to be_nil
      expect(animals.find(dam.id)).to be_expecting
    end

    it '受胎イベント(Breeding)が永続化され、breedings.for_dam(dam.id) から父を辿れること' do
      conceive
      breeding = breedings.for_dam(dam.id)
      expect(breeding.sire).to eq(sire)
      expect(breeding.dam).to eq(dam)
    end

    it 'オス同士を渡すと failure で error が BreedingNotAllowed となること' do
      other_male = build_adult(catalog.lion, name: 'もう一頭', sex: animal::Sex.male)
      animals.save(other_male)

      expect(conceive(dam_id: other_male.id).error).to be_a(Zoo::Domain::Errors::BreedingNotAllowed)
    end

    it '季節繁殖種(ニホンザル=秋)は100日進めた夏には failure で error が BreedingNotAllowed となること' do
      m_sire, m_dam = build_pair(catalog.japanese_macaque)
      m_animals = in_memory::InMemoryAnimalRepository.new([m_sire, m_dam])
      summer = Zoo::Domain::Zoo.new(name: '園', admission_fee: shared::Money.yen(2000))
      100.times { summer.advance_day }

      result = conceive(
        sire_id: m_sire.id, dam_id: m_dam.id, animals: m_animals,
        zoo: in_memory::InMemoryZooRepository.new(summer),
        breedings: in_memory::InMemoryBreedingRepository.new,
        unit_of_work: in_memory::InMemoryUnitOfWork.new(repositories: [m_animals])
      )

      expect(result.error).to be_a(Zoo::Domain::Errors::BreedingNotAllowed)
    end

    it '存在しない sire_id "missing" を渡すと failure で error が AnimalNotFound となること' do
      expect(conceive(sire_id: 'missing').error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
