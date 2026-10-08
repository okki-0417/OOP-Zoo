# frozen_string_literal: true

abort 'すでに園があります。作り直すときは bin/rails db:seed:replant を使ってください' if Zoo.exists?

zoo = Zoo.of(User.first_or_create!)

enclosures = {
  savanna: { name: 'サバンナ', celsius: 26, capacity: 8 },
  lions: { name: 'ライオンの丘', celsius: 22, capacity: 2 },
  monkeys: { name: 'サル山', celsius: 15, capacity: 4 },
  penguins: { name: 'ペンギンの浜', celsius: 16, capacity: 4 },
  polar: { name: '氷の世界', celsius: 0, capacity: 3, climate_controlled: true },
  pandas: { name: 'レッサーパンダの森', celsius: 12, capacity: 1 },
  cranes: { name: '水鳥の湿原', celsius: 15, capacity: 3 }
}.transform_values do |attributes|
  enclosure = Enclosure.new(
    name: attributes[:name], temperature: Temperature.celsius(attributes[:celsius]),
    capacity: attributes[:capacity], climate_controlled: attributes.fetch(:climate_controlled, false)
  )
  Constructing.new(zoo:, enclosure:).perform
end

residents = {
  savanna: [
    [:reticulated_giraffe, 'キリコ', :female], [:reticulated_giraffe, 'ノッポ', :male],
    [:grevys_zebra, 'シマコ', :female], [:grevys_zebra, 'ボーダー', :male]
  ],
  lions: [[:lion, 'レオ', :male], [:lion, 'ナナ', :female]],
  monkeys: [[:japanese_macaque, 'ボス', :male], [:japanese_macaque, 'モモ', :female], [:japanese_macaque, 'ハナ', :female]],
  penguins: [
    [:humboldt_penguin, 'ペン太', :male], [:humboldt_penguin, 'ペン子', :female], [:humboldt_penguin, 'チョコ', :female]
  ],
  polar: [[:polar_bear, 'ユキ', :female]],
  pandas: [[:red_panda, 'フウタ', :male]],
  cranes: [[:red_crowned_crane, 'ツル吉', :male], [:red_crowned_crane, 'ミヤビ', :female]]
}

residents.each do |home, animals|
  animals.each do |species_key, name, sex|
    animal = Animal.new(
      species: SpeciesCatalog.find!(species_key), name:, sex: Animal::Sex.new(sex),
      max_health: Acquiring::ACQUIRED_HEALTH
    )
    Acquiring.new(zoo:, animal:).perform
    Housing.new(animal:, enclosure: enclosures.fetch(home)).perform
  end
end

keepers = {
  '田中' => { specialties: %i[mammal], areas: %i[savanna lions] },
  '佐藤' => { specialties: %i[mammal], areas: %i[monkeys polar pandas] },
  '鈴木' => { specialties: %i[bird], areas: %i[penguins cranes] }
}.map do |name, plan|
  keeper = Keeper.new(name:, specialties: plan[:specialties].map { |key| Keeper::Specialty.new(taxon_class: TaxonClass.new(key)) })
  Hiring.new(zoo:, employee: keeper).perform
  plan[:areas].each { |area| Tending.new(keeper:, enclosure: enclosures.fetch(area)).perform }
  keeper
end

veterinarian = Hiring.new(zoo:, employee: Veterinarian.new(name: '高橋')).perform

random = Random.new(Integer(ENV.fetch('ZOO_SEED', 3)))

3.times do
  keepers.each do |keeper|
    keeper.reload.enclosures.each do |enclosure|
      Rounding.new(keeper:, occupancy: Occupancy.of(enclosure), foods: FoodCatalog.all).perform
    end
  end
  zoo.animals.reload.select(&:sick?).each { |animal| Treating.new(veterinarian:, animal:).perform }
  ZooDay.of(zoo.reload, random:).run
end
