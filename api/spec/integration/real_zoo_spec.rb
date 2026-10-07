# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '現実の動物園の再現' do
  shared    = Zoo::Domain::Shared
  animal    = Zoo::Domain::Animal
  taxonomy  = Zoo::Domain
  staff     = Zoo::Domain
  feeding   = Zoo::Domain
  breeding  = Zoo::Domain
  medical   = Zoo::Domain
  catalog   = taxonomy::SpeciesCatalog

  def deg(value)
    Zoo::Domain::Shared::Temperature.celsius(value)
  end

  def occupancy_of(enclosure)
    Zoo::Domain::Occupancy.of(Zoo::Domain::Enclosure.find(enclosure.id))
  end

  def occupants_of(enclosure)
    occupancy_of(enclosure).to_a
  end

  def all_occupants
    Zoo::Domain::Occupancy.all.flat_map(&:to_a)
  end

  def house(animal, enclosure)
    Zoo::Domain::Housing.new(animal:, enclosure:, occupancy: occupancy_of(enclosure)).perform
    animal.save!
    animal
  end

  def assign(keeper, enclosure)
    Zoo::Domain::Tending.new(keeper:, enclosure:, occupancy: occupancy_of(enclosure)).perform
  end

  def pass_a_day
    occupancies = Zoo::Domain::Occupancy.all
    occupancies.each do |occupancy|
      e = occupancy.enclosure
      Zoo::Domain::Infestation.new(e, occupancy).spread
      Zoo::Domain::Contagion.new(e, occupancy).spread
      occupancy.each { |animal| Zoo::Domain::AnimalDay.new(animal:, enclosure: e, occupancy:, season: Zoo::Domain::Season.spring).run }
      e.soil(occupancy.count)
      e.deplete_enrichment
      e.save!
      occupancy.each(&:save!)
    end
  end

  def build_enclosure(name, celsius, capacity)
    Zoo::Domain::Enclosure.create!(name:, temperature: deg(celsius), capacity:)
  end

  def hire(name, taxon_class)
    Zoo::Domain::Keeper.create!(name:, specialties: [taxon_class])
  end

  let(:zoo) { Zoo::Domain::Zoo.create!(name: 'おうきの動物園', admission_fee: shared::Money.yen(2000)) }

  let(:savanna) { build_enclosure('アフリカサバンナ', 30, 6) }
  let(:lion_hill) { build_enclosure('ライオンの丘', 28, 4) }
  let(:polar_sea) { build_enclosure('ホッキョクの海', -5, 2) }
  let(:penguin_pool) { build_enclosure('ペンギンプール', 0, 10) }
  let(:reptile_house) { build_enclosure('爬虫類館', 28, 2) }
  let(:monkey_mountain) { build_enclosure('モンキーマウンテン', 20, 8) }

  let(:mammal_keeper) { hire('田中', taxonomy::TaxonClass.mammal) }
  let(:bird_keeper) { hire('鈴木', taxonomy::TaxonClass.bird) }
  let(:reptile_keeper) { hire('佐藤', taxonomy::TaxonClass.reptile) }
  let(:vet) { staff::Veterinarian.create!(name: '山田') }

  let(:lions) { build_pair(catalog.lion) }
  let(:zebras) { build_pair(catalog.grevys_zebra) }
  let(:giraffe) { build_adult(catalog.reticulated_giraffe, name: 'キリン') }
  let(:polar_bear) { build_adult(catalog.polar_bear, name: 'シロ') }
  let(:penguins) { Array.new(3) { |i| build_adult(catalog.emperor_penguin, name: "ペンギン#{i}") } }
  let(:python) { build_adult(catalog.burmese_python, name: 'ニシキ') }
  let(:macaques) { build_pair(catalog.japanese_macaque) }

  before do
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
    expect(all_occupants.size).to eq(12)
    expect(occupants_of(savanna).map(&:species).uniq.size).to eq(2)
    expect(all_occupants.map(&:species).uniq.size).to eq(7)
  end

  it '飼育員が専門の綱の動物がいるエリアに担当割り当てされること' do
    expect(mammal_keeper.enclosures.reload)
      .to contain_exactly(savanna, lion_hill, polar_sea, monkey_mountain)
    expect(bird_keeper.enclosures.reload).to contain_exactly(penguin_pool)
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
    expect(occupants_of(lion_hill).size).to eq(3)
    expect(all_occupants.size).to eq(13)
    expect(cub.parents).to contain_exactly(sire, dam)
  end

  it '来園者を受け入れて収益を計上できること' do
    zoo.admit_visitors(500)
    expect(zoo.revenue).to eq(shared::Money.yen(1_000_000))
  end

  it '展示中の絶滅危惧種を把握できること' do
    names = all_occupants.select(&:threatened?).map(&:species).uniq.map(&:name_ja)
    expect(names).to include('グレビーシマウマ', 'アミメキリン', 'ライオン', 'ホッキョクグマ', 'ビルマニシキヘビ')
    expect(names).not_to include('ニホンザル')
  end

  it '一日を開園すると全個体が歳をとり、エリアが汚れること' do
    expect { pass_a_day }
      .to change { zebras.first.reload.age_in_days }.by(1)
    expect(savanna.reload.cleanliness.level).to be < 100
    expect(all_occupants.size).to eq(12)
  end
end
