# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::AlertList do
  catalog   = Zoo::Domain::SpeciesCatalog
  illnesses = Zoo::Domain::IllnessCatalog
  female    = Zoo::Domain::Animal::Sex.female

  let(:lion) { build_adult(catalog.lion, name: 'レオ') }
  let(:mate) { build_adult(catalog.lion, name: 'ナラ', sex: female) }
  let(:hill) { enclosure_at(25, name: 'ライオンの丘') }
  let(:keepers) { [build_keeper(Zoo::Domain::TaxonClass.mammal)] }
  let(:veterinarians) { [Zoo::Domain::Veterinarian.new(name: '山田')] }

  def enclosure_at(celsius, name: '丘', capacity: 4)
    Zoo::Domain::Enclosure.new(name:, temperature: Zoo::Domain::Shared::Temperature.celsius(celsius), capacity:)
  end

  def alerts(animals: [lion, mate], housed_in: hill, zoo: Factory::ZooRepository.build, keepers: self.keepers,
             veterinarians: self.veterinarians, unhoused: [], tended: true)
    tendings = tended ? keepers.map { |keeper| Zoo::Domain::Tending.new(keeper:, enclosure: housed_in) } : []
    command = Factory::AlertListCommand.with_bind(
      assignments: Factory::AssignmentRepository.build(tendings),
      animals: Factory::AnimalRepository.build(animals + unhoused),
      housings: Factory::HousingRepository.build(animals.map { |animal| housed(animal, housed_in) }),
      keepers: Factory::KeeperRepository.build(keepers),
      veterinarians: Factory::VeterinarianRepository.build(veterinarians),
      zoo:
    )
    described_class.new(command:).call.value
  end

  def kinds(list)
    list.map { |alert| [alert[:kind], alert[:subject].name] }
  end

  describe '#call' do
    it '健康なペアが快適なエリアにいて、飼育員と獣医がそろっていれば空配列を返すこと' do
      expect(alerts).to eq([])
    end

    it '残高が負なら kind=:insolvent・severity=:critical の園への警告を先頭に返すこと' do
      zoo = Factory::ZooRepository.build(funds: 0)
      zoo.save(zoo.load.tap { |z| z.spend(Zoo::Domain::Shared::Money.yen(5_000)) })

      first = alerts(zoo:).first
      expect(first).to include(kind: :insolvent, severity: :critical, subject_type: :zoo,
                               message: '資金が赤字です(残高 -¥5,000)')
    end

    it '収容中の綱(哺乳類)を専門とする飼育員がいなければ kind=:no_keeper を返すこと' do
      expect(alerts(keepers: [build_keeper(Zoo::Domain::TaxonClass.bird)]).map { |alert| alert[:message] })
        .to include('哺乳類を世話できる飼育員がいません')
    end

    it '病気の個体がいて獣医が0人なら kind=:no_veterinarian を返し、獣医がいれば返さないこと' do
      lion.fall_ill(illnesses.cold)
      expect(kinds(alerts(veterinarians: []))).to include([:no_veterinarian, 'テスト動物園'])
      expect(kinds(alerts)).not_to include([:no_veterinarian, 'テスト動物園'])
    end

    it '不潔なエリアは kind=:filthy、刺激の乏しいエリアは kind=:barren で返すこと' do
      hill.soil(80)
      hill.deplete_enrichment(80)
      expect(kinds(alerts)).to include([:filthy, 'ライオンの丘'], [:barren, 'ライオンの丘'])
    end

    it '動物がいるのに担当の飼育員がいないエリアは kind=:unassigned で返すこと' do
      expect(kinds(alerts(tended: false))).to include([:unassigned, 'ライオンの丘'])
    end

    it '過密なエリアは kind=:overcrowded で返すこと' do
      cramped = enclosure_at(25, name: '狭い檻', capacity: 1)
      expect(kinds(alerts(housed_in: cramped))).to include([:overcrowded, '狭い檻'])
    end

    it '肺炎のライオンは kind=:sick と予後 kind=:guarded(12日以内に病死)を返すこと' do
      lion.fall_ill(illnesses.pneumonia)
      list = alerts.select { |alert| alert[:subject].name == 'レオ' }

      expect(list.map { |alert| alert[:kind] }).to include(:guarded, :sick)
      expect(list.find { |alert| alert[:kind] == :guarded }[:message]).to eq('このままだと12日以内に病死する見込みです')
      expect(list.find { |alert| alert[:kind] == :sick }[:message])
        .to eq('肺炎にかかっています。同居個体にうつるおそれがあります')
    end

    it '体力がわずかで重病の個体は予後 kind=:grave・severity=:critical を返すこと' do
      dying = build_adult(catalog.lion, name: '瀕死', max_health: 10)
      dying.fall_ill(illnesses.pneumonia)

      expect(alerts(animals: [dying, mate]).first).to include(kind: :grave, severity: :critical)
    end

    it '飢餓状態なら kind=:starving(critical)、飢餓まで2日以内なら kind=:hungry(warning) を返すこと' do
      lion.get_hungrier(100)
      mate.get_hungrier(85)

      expect(alerts.map { |alert| [alert[:kind], alert[:severity], alert[:subject].name] })
        .to include([:starving, :critical, 'レオ'], [:hungry, :warning, 'ナラ'])
    end

    it '栄養失調なら kind=:malnourished を返すこと' do
      3.times { lion.settle_nutrition }
      expect(kinds(alerts)).to include([:malnourished, 'レオ'])
    end

    it 'ストレス60以上なら notice、90以上なら warning の kind=:stressed を返すこと' do
      lion.add_stress(60)
      mate.add_stress(90)
      stressed = alerts.select { |alert| alert[:kind] == :stressed }

      expect(stressed.map { |alert| [alert[:subject].name, alert[:severity]] })
        .to contain_exactly(['レオ', :notice], ['ナラ', :warning])
    end

    it '体感温度が生存可能域の外なら warning、快適域の外なら notice の kind=:climate を返すこと' do
      frozen_hill = enclosure_at(-30, name: '氷室')
      expect(alerts(housed_in: frozen_hill).find { |alert| alert[:kind] == :climate })
        .to include(severity: :warning, message: '氷室の体感-30.0℃は生存可能域の外です')
    end

    it '出産の時期を迎えたメスは kind=:due を返すこと' do
      mate.conceive
      mate.gestate(catalog.lion.gestation_period_days)
      expect(kinds(alerts)).to include([:due, 'ナラ'])
    end

    it '生きているのにどのエリアにもいない個体は kind=:unhoused、死亡個体は対象外であること' do
      stray = build_adult(catalog.lion, name: '迷子')
      dead = build_adult(catalog.lion, name: '故').die

      expect(kinds(alerts(unhoused: [stray, dead]))).to include([:unhoused, '迷子'])
      expect(kinds(alerts(unhoused: [stray, dead]))).not_to include([:unhoused, '故'])
    end

    it 'critical → warning → notice の順、同じ重大度では園への警告を先に並べること' do
      zoo = Factory::ZooRepository.build(funds: 0)
      zoo.save(zoo.load.tap { |z| z.spend(Zoo::Domain::Shared::Money.yen(1)) })
      lion.add_stress(60)
      lion.get_hungrier(85)

      list = alerts(zoo:, keepers: [])
      expect(list.map { |alert| alert[:severity] }).to eq(%i[critical warning warning warning notice])
      expect(list[1]).to include(kind: :no_keeper)
    end
  end
end
