# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '現実の動物園の再現' do
  shared    = Zoo::Domain::Shared
  animal    = Zoo::Domain::Animal
  taxonomy  = Zoo::Domain
  husbandry = Zoo::Domain
  staff     = Zoo::Domain
  feeding   = Zoo::Domain
  breeding  = Zoo::Domain
  medical   = Zoo::Domain
  catalog   = taxonomy::SpeciesCatalog

  def deg(value)
    Zoo::Domain::Shared::Temperature.celsius(value)
  end

  def occupancy
    Zoo::Domain::Occupancy.new(@housings)
  end

  def house(animal, enclosure)
    housing = Zoo::Domain::Housing.new(animal: animal, enclosure: enclosure, occupancy: occupancy)
    housing.admission_violation!

    @housings << housing
    animal
  end

  def pass_a_day
    zoo.enclosures.flat_map { |e| Zoo::Domain::EnclosureDay.new(e, occupancy.occupants_of(e)).run }
  end

  let(:zoo) { Zoo::Domain::Zoo.new(name: 'おうきの動物園', admission_fee: shared::Money.yen(2000)) }

  let(:savanna) { zoo.add_enclosure(husbandry::Enclosure.new(name: 'アフリカサバンナ', temperature: deg(30), capacity: 6)) }
  let(:lion_hill) { zoo.add_enclosure(husbandry::Enclosure.new(name: 'ライオンの丘', temperature: deg(28), capacity: 4)) }
  let(:polar_sea) { zoo.add_enclosure(husbandry::Enclosure.new(name: 'ホッキョクの海', temperature: deg(-5), capacity: 2)) }
  let(:penguin_pool) { zoo.add_enclosure(husbandry::Enclosure.new(name: 'ペンギンプール', temperature: deg(0), capacity: 10)) }
  let(:reptile_house) { zoo.add_enclosure(husbandry::Enclosure.new(name: '爬虫類館', temperature: deg(28), capacity: 2)) }
  let(:monkey_mountain) do
    zoo.add_enclosure(husbandry::Enclosure.new(name: 'モンキーマウンテン', temperature: deg(20), capacity: 8))
  end

  let(:mammal_keeper) { zoo.hire_keeper(staff::Keeper.new(name: '田中', specialties: [taxonomy::TaxonClass.mammal])) }
  let(:bird_keeper) { zoo.hire_keeper(staff::Keeper.new(name: '鈴木', specialties: [taxonomy::TaxonClass.bird])) }
  let(:reptile_keeper) { zoo.hire_keeper(staff::Keeper.new(name: '佐藤', specialties: [taxonomy::TaxonClass.reptile])) }
  let(:vet) { zoo.hire_veterinarian(staff::Veterinarian.new(name: '山田')) }

  let(:lions) { build_pair(catalog.lion) }
  let(:zebras) { build_pair(catalog.grevys_zebra) }
  let(:giraffe) { build_adult(catalog.reticulated_giraffe, name: 'キリン') }
  let(:polar_bear) { build_adult(catalog.polar_bear, name: 'シロ') }
  let(:penguins) { Array.new(3) { |i| build_adult(catalog.emperor_penguin, name: "ペンギン#{i}") } }
  let(:python) { build_adult(catalog.burmese_python, name: 'ニシキ') }
  let(:macaques) { build_pair(catalog.japanese_macaque) }

  before do
    @housings = []
    zebras.each { |z| house(z, savanna) }
    house(giraffe, savanna)

    lions.each { |l| house(l, lion_hill) }
    house(polar_bear, polar_sea)
    penguins.each { |p| house(p, penguin_pool) }
    house(python, reptile_house)
    macaques.each { |m| house(m, monkey_mountain) }

    mammal_keeper.assign_to(savanna).assign_to(lion_hill).assign_to(polar_sea).assign_to(monkey_mountain)
    bird_keeper.assign_to(penguin_pool)
    reptile_keeper.assign_to(reptile_house)
  end

  it '多様な動物が適切な環境に収容され、混合展示が成立すること' do
    expect(occupancy.all_occupants.size).to eq(12)
    expect(occupancy.species_present_in(savanna).size).to eq(2)
    expect(occupancy.all_occupants.map(&:species).uniq.size).to eq(7)
  end

  it '肉食獣を草食動物の展示に同居させられないこと' do
    rogue_lion = build_adult(catalog.lion, name: 'はぐれ')
    expect { house(rogue_lion, savanna) }
      .to raise_error(Zoo::Domain::Errors::HousingNotAllowed, /捕食/)
  end

  it '気候の合わない動物を収容できないこと(ホッキョクグマをサバンナへ)' do
    misplaced = build_adult(catalog.polar_bear, name: '迷子')
    expect { house(misplaced, savanna) }
      .to raise_error(Zoo::Domain::Errors::HousingNotAllowed, /適応/)
  end

  it '飼育員が専門の動物に給餌でき、専門外には給餌できないこと' do
    zebras.first.get_hungrier(40)
    satiety = catalog.grevys_zebra.satiety_from(feeding::FoodCatalog.hay)
    mammal_keeper.feed(zebras.first, feeding::FoodCatalog.hay)
    expect(zebras.first.hunger_level).to eq(40 - satiety)

    expect { mammal_keeper.feed(penguins.first, feeding::FoodCatalog.sardine) }
      .to raise_error(Zoo::Domain::Errors::NotQualified)

    penguins.first.get_hungrier(30)
    expect { bird_keeper.feed(penguins.first, feeding::FoodCatalog.sardine) }.not_to raise_error
  end

  it '病気の動物を獣医が診て治療できること' do
    patient = penguins.first
    patient.fall_ill(medical::IllnessCatalog.pneumonia)
    expect(vet.examine(patient)).to eq(:sick)

    vet.treat(patient)
    expect(patient).not_to be_sick
    expect(vet.examine(patient)).to eq(:healthy)
  end

  it 'ライオンを繁殖させ、生まれた子を群れに加えられること' do
    sire, dam = lions
    dam.conceive
    dam.gestate(catalog.lion.gestation_period_days)
    cub = Zoo::Domain::Birth.new(sire: sire, dam: dam, name: 'シンバ').deliver.offspring

    house(cub, lion_hill)
    expect(occupancy.population_of(lion_hill)).to eq(3)
    expect(occupancy.all_occupants.size).to eq(13)
    expect(dam.pull_events.last).to be_a(Zoo::Domain::Events::Birth)
    expect(cub.parent_ids).to contain_exactly(sire.id, dam.id)
  end

  it '来園者を受け入れて収益を計上できること' do
    zoo.admit_visitors(500)
    expect(zoo.revenue).to eq(shared::Money.yen(1_000_000))
  end

  it '展示中の絶滅危惧種を把握できること' do
    names = occupancy.all_occupants.select(&:threatened?).map(&:species).uniq.map(&:name_ja)
    expect(names).to include('グレビーシマウマ', 'アミメキリン', 'ライオン', 'ホッキョクグマ', 'ビルマニシキヘビ')
    expect(names).not_to include('ニホンザル')
  end

  it '一日を開園すると全個体が歳をとり、エリアが汚れること' do
    expect { pass_a_day }
      .to change { zebras.first.age_in_days }.by(1)
    expect(savanna.cleanliness.level).to be < 100
    expect(occupancy.all_occupants.size).to eq(12)
  end
end
