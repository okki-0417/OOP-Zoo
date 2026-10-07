# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '現実の動物園の再現' do
  def deg(value)
    Temperature.celsius(value)
  end

  def occupancy_of(enclosure)
    Occupancy.of(Enclosure.find(enclosure.id))
  end

  def occupants_of(enclosure)
    occupancy_of(enclosure).to_a
  end

  def all_occupants
    Occupancy.all.flat_map(&:to_a)
  end

  def house(animal, enclosure)
    Housing.new(animal:, enclosure:, occupancy: occupancy_of(enclosure)).perform
    animal.save!
    animal
  end

  def assign(keeper, enclosure)
    Tending.new(keeper:, enclosure:, occupancy: occupancy_of(enclosure)).perform
  end

  def pass_a_day
    occupancies = Occupancy.all
    occupancies.each do |occupancy|
      e = occupancy.enclosure
      Infestation.new(e, occupancy).spread
      Contagion.new(e, occupancy).spread
      occupancy.each { |animal| AnimalDay.new(animal:, enclosure: e, occupancy:, season: Season.spring).run }
      e.soil(occupancy.count)
      e.deplete_enrichment
      e.save!
      occupancy.each(&:save!)
    end
  end

  def build_enclosure(name, celsius, capacity)
    Enclosure.create!(name:, temperature: deg(celsius), capacity:)
  end

  def hire(name, taxon_class)
    Keeper.create!(name:, specialties: [taxon_class])
  end

  let(:zoo) { Zoo.create!(name: 'おうきの動物園', admission_fee: Money.yen(2000)) }

  let(:savanna) { build_enclosure('アフリカサバンナ', 30, 6) }
  let(:lion_hill) { build_enclosure('ライオンの丘', 28, 4) }
  let(:polar_sea) { build_enclosure('ホッキョクの海', -5, 2) }
  let(:penguin_pool) { build_enclosure('ペンギンプール', 0, 10) }
  let(:reptile_house) { build_enclosure('爬虫類館', 28, 2) }
  let(:monkey_mountain) { build_enclosure('モンキーマウンテン', 20, 8) }

  let(:mammal_keeper) { hire('田中', TaxonClass.mammal) }
  let(:bird_keeper) { hire('鈴木', TaxonClass.bird) }
  let(:reptile_keeper) { hire('佐藤', TaxonClass.reptile) }
  let(:vet) { Veterinarian.create!(name: '山田') }

  let(:lions) { build_pair(SpeciesCatalog.lion) }
  let(:zebras) { build_pair(SpeciesCatalog.grevys_zebra) }
  let(:giraffe) { build_adult(SpeciesCatalog.reticulated_giraffe, name: 'キリン') }
  let(:polar_bear) { build_adult(SpeciesCatalog.polar_bear, name: 'シロ') }
  let(:penguins) { Array.new(3) { |i| build_adult(SpeciesCatalog.emperor_penguin, name: "ペンギン#{i}") } }
  let(:python) { build_adult(SpeciesCatalog.burmese_python, name: 'ニシキ') }
  let(:macaques) { build_pair(SpeciesCatalog.japanese_macaque) }

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
      .to raise_error(Errors::AssignmentNotAllowed, /哺乳類/)
  end

  it '肉食獣を草食動物の展示に同居させられないこと' do
    rogue_lion = build_adult(SpeciesCatalog.lion, name: 'はぐれ')
    expect { house(rogue_lion, savanna) }
      .to raise_error(Errors::HousingNotAllowed, /捕食/)
  end

  it '気候の合わない動物を収容できないこと(ホッキョクグマをサバンナへ)' do
    misplaced = build_adult(SpeciesCatalog.polar_bear, name: '迷子')
    expect { house(misplaced, savanna) }
      .to raise_error(Errors::HousingNotAllowed, /適応/)
  end

  it '飼育員が専門の動物に給餌でき、専門外には給餌できないこと' do
    zebras.first.get_hungrier(40)
    hay = FoodCatalog.hay
    satiety = Feeding.new(animal: zebras.first, foods: [hay]).satiety
    Feeding.new(keeper: mammal_keeper, animal: zebras.first, foods: [hay]).serve
    expect(zebras.first.hunger_level).to eq(40 - satiety)

    sardine = FoodCatalog.sardine
    expect { Feeding.new(keeper: mammal_keeper, animal: penguins.first, foods: [sardine]).serve }
      .to raise_error(Errors::FeedingNotAllowed)

    penguins.first.get_hungrier(30)
    expect { Feeding.new(keeper: bird_keeper, animal: penguins.first, foods: [sardine]).serve }
      .not_to raise_error
  end

  it '病気の動物を獣医が診て治療できること' do
    patient = penguins.first
    patient.fall_ill(IllnessCatalog.pneumonia)
    expect(Examining.new(veterinarian: vet, animal: patient).diagnosis).to eq(:sick)

    Treating.new(veterinarian: vet, animal: patient).perform
    expect(patient).not_to be_sick
    expect(Examining.new(veterinarian: vet, animal: patient).diagnosis).to eq(:healthy)
  end

  it 'ライオンを繁殖させ、生まれた子を群れに加えられること' do
    sire, dam = lions
    dam.conceive
    dam.gestate(SpeciesCatalog.lion.gestation_period_days)
    cub = Birth.new(sire: sire, dam: dam, name: 'シンバ').deliver.offspring

    house(cub, lion_hill)
    expect(occupants_of(lion_hill).size).to eq(3)
    expect(all_occupants.size).to eq(13)
    expect(cub.parents).to contain_exactly(sire, dam)
  end

  it '来園者を受け入れて収益を計上できること' do
    zoo.admit_visitors(500)
    expect(zoo.revenue).to eq(Money.yen(1_000_000))
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
