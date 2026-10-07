# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::ConceiveAnimals do
  animal  = Zoo::Domain::Animal
  catalog = Zoo::Domain::SpeciesCatalog

  let!(:zoo) { create_zoo }
  let!(:pair) { build_pair(catalog.lion).each(&:save!) }
  let(:sire) { pair[0] }
  let(:dam)  { pair[1] }

  def conceive(sire_id: sire.id, dam_id: dam.id)
    described_class.new(command: Zoo::Application::Commands::ConceiveAnimalsCommand.new(sire_id:, dam_id:)).call
  end

  describe '#call' do
    it 'sire/dam の id を渡すと success で value が nil になり、保存された dam が妊娠状態になること' do
      result = conceive

      expect(result.value).to be_nil
      expect(dam.reload).to be_expecting
    end

    it '受胎記録(Breeding)が永続化され、Breeding.latest_of(dam) から父を辿れること' do
      conceive

      breeding = Zoo::Domain::Breeding.latest_of(dam)
      expect(breeding.sire).to eq(sire)
      expect(breeding.dam).to eq(dam)
    end

    it 'オス同士を渡すと failure で error が BreedingNotAllowed となり、受胎記録は残らないこと' do
      other_male = build_adult(catalog.lion, name: 'もう一頭', sex: animal::Sex.male).tap(&:save!)

      expect(conceive(dam_id: other_male.id).error).to be_a(Zoo::Domain::Errors::BreedingNotAllowed)
      expect(Zoo::Domain::Breeding.count).to eq(0)
    end

    it '季節繁殖種(ニホンザル=秋)は100日進めた夏には failure で error が BreedingNotAllowed となること' do
      m_sire, m_dam = build_pair(catalog.japanese_macaque).each(&:save!)
      100.times { zoo.advance_day }
      zoo.save!

      result = conceive(sire_id: m_sire.id, dam_id: m_dam.id)

      expect(result.error).to be_a(Zoo::Domain::Errors::BreedingNotAllowed)
      expect(m_dam.reload).not_to be_expecting
    end

    it '存在しない sire_id "missing" を渡すと failure で error が AnimalNotFound となること' do
      expect(conceive(sire_id: 'missing').error).to be_a(Zoo::Application::Errors::AnimalNotFound)
    end
  end
end
