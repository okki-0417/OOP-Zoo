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

  def house(animal, enclosure)
    occupancy = Zoo::Domain::Occupancy.new(enclosure, @housings.occupants_of(enclosure))
    housing = Zoo::Domain::Housing.new(animal: animal, enclosure: enclosure, occupancy: occupancy)
    housing.admission_violation!

    @housings.save(housing)
    animal
  end

  def assign(keeper, enclosure)
    tending = Zoo::Domain::Tending.new(
      keeper: keeper, enclosure: enclosure,
      occupancy: Zoo::Domain::Occupancy.new(enclosure, @housings.occupants_of(enclosure)),
      assignment: Zoo::Domain::Assignment.new(enclosure, @assignments.keepers_of(enclosure))
    )
    tending.violation!

    @assignments.save(tending)
    keeper
  end

  def pass_a_day
    zoo.enclosures.flat_map { |e| Zoo::Domain::EnclosureDay.new(e, @housings.occupants_of(e)).run }
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
    @housings = Zoo::Infrastructure::InMemory::InMemoryHousingRepository.new
    @assignments = Zoo::Infrastructure::InMemory::InMemoryAssignmentRepository.new
    zebras.each { |z| house(z, savanna) }
    house(giraffe, savanna)

    lions.each { |l| house(l, lion_hill) }
    house(polar_bear, polar_sea)
    penguins.each { |p| house(p, penguin_pool) }
    house(python, reptile_house)
    macaques.each { |m| house(m, monkey_mountain) }

    [savanna, lion_hill, polar_sea, monkey_mountain].each { |e| assign(mammal_keeper, e) }
    assign(bird_keeper, penguin_pool)
    assign(reptile_keeper, reptile_house)
  end

  it '多様な動物が適切な環境に収容され、混合展示が成立すること' do
    expect(@housings.all_occupants.size).to eq(12)
    expect(@housings.occupants_of(savanna).map(&:species).uniq.size).to eq(2)
    expect(@housings.all_occupants.map(&:species).uniq.size).to eq(7)
  end

  it '飼育員が専門の綱の動物がいるエリアに担当割り当てされること' do
    expect(@assignments.enclosures_of(mammal_keeper))
      .to contain_exactly(savanna, lion_hill, polar_sea, monkey_mountain)
    expect(@assignments.enclosures_of(bird_keeper)).to contain_exactly(penguin_pool)
  end

  it '専門外の綱の動物がいるエリアには担当割り当てできないこと' do
    expect { assign(bird_keeper, savanna) }
      .to raise_error(Zoo::Domain::Errors::AssignmentNotAllowed, /哺乳類/)
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
    hay = feeding::FoodCatalog.hay
    satiety = feeding::Feeding.new(animal: zebras.first, foods: [hay]).satiety
    feeding::Feeding.new(keeper: mammal_keeper, animal: zebras.first, foods: [hay]).serve
    expect(zebras.first.hunger_level).to eq(40 - satiety)

    sardine = feeding::FoodCatalog.sardine
    expect { feeding::Feeding.new(keeper: mammal_keeper, animal: penguins.first, foods: [sardine]).serve }
      .to raise_error(Zoo::Domain::Errors::FeedingNotAllowed)

    penguins.first.get_hungrier(30)
    expect { feeding::Feeding.new(keeper: bird_keeper, animal: penguins.first, foods: [sardine]).serve }
      .not_to raise_error
  end

  it '病気の動物を獣医が診て治療できること' do
    patient = penguins.first
    patient.fall_ill(medical::IllnessCatalog.pneumonia)
    expect(medical::Examining.new(veterinarian: vet, animal: patient).diagnosis).to eq(:sick)

    medical::Treating.new(veterinarian: vet, animal: patient).perform
    expect(patient).not_to be_sick
    expect(medical::Examining.new(veterinarian: vet, animal: patient).diagnosis).to eq(:healthy)
  end

  it 'ライオンを繁殖させ、生まれた子を群れに加えられること' do
    sire, dam = lions
    dam.conceive
    dam.gestate(catalog.lion.gestation_period_days)
    cub = Zoo::Domain::Birth.new(sire: sire, dam: dam, name: 'シンバ').deliver.offspring

    house(cub, lion_hill)
    expect(@housings.occupants_of(lion_hill).size).to eq(3)
    expect(@housings.all_occupants.size).to eq(13)
    expect(dam.pull_events.last).to be_a(Zoo::Domain::Events::Birth)
    expect(cub.parent_ids).to contain_exactly(sire.id, dam.id)
  end

  it '来園者を受け入れて収益を計上できること' do
    zoo.admit_visitors(500)
    expect(zoo.revenue).to eq(shared::Money.yen(1_000_000))
  end

  it '展示中の絶滅危惧種を把握できること' do
    names = @housings.all_occupants.select(&:threatened?).map(&:species).uniq.map(&:name_ja)
    expect(names).to include('グレビーシマウマ', 'アミメキリン', 'ライオン', 'ホッキョクグマ', 'ビルマニシキヘビ')
    expect(names).not_to include('ニホンザル')
  end

  it '一日を開園すると全個体が歳をとり、エリアが汚れること' do
    expect { pass_a_day }
      .to change { zebras.first.age_in_days }.by(1)
    expect(savanna.cleanliness.level).to be < 100
    expect(@housings.all_occupants.size).to eq(12)
  end
end
