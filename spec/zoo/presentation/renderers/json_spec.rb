# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Presentation::Renderers::Json do
  result = Zoo::Application::Result
  read_models = Zoo::Application::ReadModels
  catalog = Zoo::Domain::SpeciesCatalog

  describe '.render(failure)' do
    it 'ApplicationError(AnimalNotFound) は 404 と {error:{code:"AnimalNotFound", message:}} になること' do
      failure = result.failure(:animal_detail, Zoo::Application::Errors::AnimalNotFound.new('動物 x は存在しません'))

      expect(described_class.render(failure))
        .to eq([404, { error: { code: 'AnimalNotFound', message: '動物 x は存在しません' } }])
    end

    it 'DomainError(CapacityExceeded) は 422 と {error:{code:"CapacityExceeded"}} になること' do
      failure = result.failure(:house_animal, Zoo::Domain::Errors::CapacityExceeded.new('満員'))

      status, body = described_class.render(failure)

      expect(status).to eq(422)
      expect(body[:error]).to include(code: 'CapacityExceeded', message: '満員')
    end
  end

  describe '.render(success)' do
    it 'acquire_animal の AnimalProfile は 201 と name/species/enclosure_id=nil を含む本文になること' do
      profile = read_models::AnimalProfile.of(build_adult(catalog.lion, name: 'レオ'), enclosure: nil)

      status, body = described_class.render(result.success(:acquire_animal, profile))

      expect(status).to eq(201)
      expect(body).to include(name: 'レオ', species: 'ライオン', enclosure_id: nil)
    end

    it 'admit_visitors の Money(¥20000) は 200 と {revenue: 20000} になること' do
      revenue = Zoo::Domain::Shared::Money.yen(20_000)

      expect(described_class.render(result.success(:admit_visitors, revenue))).to eq([200, { revenue: 20_000 }])
    end

    it 'species_list の {lion: Species} は 200 と key="lion" の配列になること' do
      status, body = described_class.render(result.success(:species_list, { lion: catalog.lion }))

      expect(status).to eq(200)
      expect(body).to contain_exactly(include(key: 'lion', name_ja: 'ライオン'))
    end

    it 'taxon_class_list の [TaxonClass.mammal] は 200 と [{key:"mammal", label:"哺乳類"}] になること' do
      rendered = described_class.render(result.success(:taxon_class_list, [Zoo::Domain::TaxonClass.mammal]))

      expect(rendered).to eq([200, [{ key: 'mammal', label: '哺乳類' }]])
    end

    it 'ビューが登録されていない service(:population) の success は KeyError になること' do
      expect { described_class.render(result.success(:population, 3)) }.to raise_error(KeyError)
    end
  end

  describe '.views' do
    it 'すべてのキーが Result::SERVICES に含まれていること' do
      expect(described_class.views.keys - result::SERVICES).to be_empty
    end
  end
end
