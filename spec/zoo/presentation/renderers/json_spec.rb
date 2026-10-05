# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Presentation::Renderers::Json do
  result = Zoo::Application::Result
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
    it 'acquire_animal の {animal: レオ, enclosure: nil} は 201 と name/species/enclosure_id=nil を含む本文になること' do
      view = { animal: build_adult(catalog.lion, name: 'レオ'), enclosure: nil }

      status, body = described_class.render(result.success(:acquire_animal, view))

      expect(status).to eq(201)
      expect(body).to include(name: 'レオ', species: 'ライオン', enclosure_id: nil)
    end

    it 'animal_detail の {animal:, enclosure:} は栄養・ストレス・妊娠・その日の食事・食べられる餌の分類を含む本文になること' do
      lion = build_adult(catalog.lion, name: 'レオ')
      lion.take_meal([:meat])

      _status, body = described_class.render(result.success(:animal_detail, { animal: lion, enclosure: nil }))
      expect(body).to include(
        nutrition: 100, malnourished: false, stress: 0, stressed: false, severely_stressed: false,
        hungry: false, days_until_starving: 10, meals_today: ['meat'], contagious: false,
        expecting: false, gestation_days: nil, gestation_period_days: 110, ready_to_deliver: false,
        diet_categories: ['meat'], cause: nil
      )
    end

    it 'animal_detail の enclosure に丘を渡すと enclosure_id/enclosure_name が丘のものになること' do
      hill = Zoo::Domain::Enclosure.new(name: '丘', temperature: Zoo::Domain::Shared::Temperature.celsius(25), capacity: 4)
      view = { animal: build_adult(catalog.lion, name: 'レオ'), enclosure: hill }

      _status, body = described_class.render(result.success(:animal_detail, view))
      expect(body).to include(enclosure_id: hill.id.to_s, enclosure_name: '丘')
    end

    it 'animal_prognosis の prognosis(outlook=:guarded) は housed=true で outlook を文字列にした本文になること' do
      lion = build_adult(catalog.lion, name: 'レオ')
      prognosis = Struct.new(:outlook, :days_to_death, :cause_of_death_label).new(:guarded, 12, '病死')

      expect(described_class.render(result.success(:animal_prognosis, { animal: lion, prognosis: }))).to eq(
        [200, { animal_id: lion.id.to_s, housed: true, outlook: 'guarded', days_to_death: 12, cause_of_death: '病死' }]
      )
    end

    it 'animal_prognosis の prognosis=nil は housed=false で見通しを nil にした本文になること' do
      lion = build_adult(catalog.lion, name: 'レオ')

      expect(described_class.render(result.success(:animal_prognosis, { animal: lion, prognosis: nil }))).to eq(
        [200, { animal_id: lion.id.to_s, housed: false, outlook: nil, days_to_death: nil, cause_of_death: nil }]
      )
    end

    it 'alert_list のエリア宛て alert は severity/kind を文字列に、subject を {type, id, name} にした配列になること' do
      hill = Zoo::Domain::Enclosure.new(name: '丘', temperature: Zoo::Domain::Shared::Temperature.celsius(25), capacity: 4)
      alert = { severity: :warning, kind: :filthy, subject_type: :enclosure, subject: hill, message: '不潔です' }

      expect(described_class.render(result.success(:alert_list, [alert]))).to eq(
        [200, [{ severity: 'warning', kind: 'filthy', subject: { type: 'enclosure', id: hill.id.to_s, name: '丘' },
                 message: '不潔です' }]]
      )
    end

    it 'alert_list の園宛て alert は subject.id が nil になること' do
      zoo = Zoo::Domain::Zoo.new(name: 'テスト動物園', admission_fee: Zoo::Domain::Shared::Money.yen(2_000))
      alert = { severity: :critical, kind: :insolvent, subject_type: :zoo, subject: zoo, message: '赤字' }

      _status, body = described_class.render(result.success(:alert_list, [alert]))
      expect(body.first[:subject]).to eq(type: 'zoo', id: nil, name: 'テスト動物園')
    end

    it 'checklist の chore は items の done を数えて done_count=1/total=2 にし、subject を入れ子にした配列になること' do
      temperature = Zoo::Domain::Shared::Temperature.celsius(25)
      hill = Zoo::Domain::Enclosure.new(name: '丘', temperature:, capacity: 4)
      valley = Zoo::Domain::Enclosure.new(name: '谷', temperature:, capacity: 4)
      chore = { kind: :cleaning, label: '清掃',
                items: [{ type: :enclosure, subject: hill, done: true }, { type: :enclosure, subject: valley, done: false }] }

      expect(described_class.render(result.success(:checklist, [chore]))).to eq(
        [200, [{ kind: 'cleaning', label: '清掃', done_count: 1, total: 2,
                 items: [{ subject: { type: 'enclosure', id: hill.id.to_s, name: '丘' }, done: true },
                         { subject: { type: 'enclosure', id: valley.id.to_s, name: '谷' }, done: false }] }]]
      )
    end

    it 'animal_detail のレオ(成体オス)は species/taxon_class/sex/life_stage を日本語ラベルにすること' do
      _status, body = described_class.render(
        result.success(:animal_detail, { animal: build_adult(catalog.lion, name: 'レオ'), enclosure: nil })
      )

      expect(body).to include(name: 'レオ', species: 'ライオン', taxon_class: '哺乳類', sex: 'オス', life_stage: '成体',
                              max_health: 100, alive: true)
    end

    it 'animal_list の満タンで健康なレオは health=max_health=100・ailing=false・hungry=false になること' do
      _status, body = described_class.render(result.success(:animal_list, [build_adult(catalog.lion, name: 'レオ')]))

      expect(body.first).to include(name: 'レオ', health: 100, max_health: 100, ailing: false, hungry: false)
    end

    it 'animal_list の肺炎のレオは ailing=true、死亡したレオは ailing=false になること' do
      sick = build_adult(catalog.lion, name: '病').tap { |animal| animal.fall_ill(Zoo::Domain::IllnessCatalog.pneumonia) }
      dead = build_adult(catalog.lion, name: '死').tap(&:die)

      _status, body = described_class.render(result.success(:animal_list, [sick, dead]))

      expect(body.map { |row| row[:ailing] }).to eq([true, false])
    end

    it 'enclosure_detail の設定28℃・空調なしの丘は celsius=28.0・climate_controlled=false・population=住人数になること' do
      hill = Zoo::Domain::Enclosure.new(name: '丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4)
      view = { enclosure: hill, occupants: [build_adult(catalog.lion, name: 'レオ')], keepers: [] }

      _status, body = described_class.render(result.success(:enclosure_detail, view))

      expect(body).to include(id: hill.id.to_s, name: '丘', celsius: 28.0, climate_controlled: false, capacity: 4,
                              population: 1, cleanliness: 100, filthy: false, keepers: [])
      expect(body[:occupants].map { |row| row[:name] }).to eq(['レオ'])
    end

    it 'keeper_list の哺乳類専門の飼育員は specialties を日本語ラベルにし、担当エリアを {id, name} にすること' do
      keeper = build_keeper(Zoo::Domain::TaxonClass.mammal)
      hill = Zoo::Domain::Enclosure.new(name: '丘', temperature: Zoo::Domain::Shared::Temperature.celsius(28), capacity: 4)

      _status, body = described_class.render(result.success(:keeper_list, [{ keeper:, enclosures: [hill] }]))

      expect(body.first).to include(specialties: '哺乳類', worked_minutes: 0, remaining_minutes: 480,
                                    enclosures: [{ id: hill.id.to_s, name: '丘' }])
    end

    it 'deceased_list の老衰で死んだレオは {name, species, cause: "老衰"} になること' do
      lion = build_adult(catalog.lion, name: 'レオ').die(cause: :old_age)

      expect(described_class.render(result.success(:deceased_list, [lion])))
        .to eq([200, [{ name: 'レオ', species: 'ライオン', cause: '老衰' }]])
    end

    it 'threatened_species のグレビーシマウマ2頭は status_code="EN"・status_label="絶滅危惧"・count=2 になること' do
      view = { species: catalog.grevys_zebra, count: 2 }

      expect(described_class.render(result.success(:threatened_species, [view])))
        .to eq([200, [{ name_ja: 'グレビーシマウマ', status_code: 'EN', status_label: '絶滅危惧', count: 2 }]])
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
