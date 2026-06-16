# frozen_string_literal: true

module Zoo
  module Domain
    module Taxonomy
      module SpeciesCatalog
        module_function

        def temp(value)
          Shared::Temperature.celsius(value)
        end

        def lion
          Species.new(
            name_ja: 'ライオン', scientific_name: 'Panthera leo',
            taxon_class: TaxonClass.mammal, diet_type: DietType.carnivore,
            conservation_status: ConservationStatus.vulnerable,
            habitable_temperature_range: temp(10)..temp(40),
            lifespan_years: 15, maturity_age_years: 3, gestation_period_days: 110,
            adult_weight: Weight.from_kilograms(190),
            default_voice: 'ガオー', group_living: true,
            litter_size: 3, charisma: 90
          )
        end

        def african_elephant
          Species.new(
            name_ja: 'アフリカゾウ', scientific_name: 'Loxodonta africana',
            taxon_class: TaxonClass.mammal, diet_type: DietType.herbivore,
            conservation_status: ConservationStatus.endangered,
            habitable_temperature_range: temp(12)..temp(40),
            lifespan_years: 60, maturity_age_years: 12, gestation_period_days: 660,
            adult_weight: Weight.from_tons(5),
            default_voice: 'パオーン', group_living: true,
            litter_size: 1, charisma: 95
          )
        end

        def reticulated_giraffe
          Species.new(
            name_ja: 'アミメキリン', scientific_name: 'Giraffa reticulata',
            taxon_class: TaxonClass.mammal, diet_type: DietType.herbivore,
            conservation_status: ConservationStatus.endangered,
            habitable_temperature_range: temp(12)..temp(40),
            lifespan_years: 25, maturity_age_years: 4, gestation_period_days: 450,
            adult_weight: Weight.from_kilograms(1200),
            default_voice: nil, group_living: true,
            litter_size: 1, charisma: 85
          )
        end

        def grevys_zebra
          Species.new(
            name_ja: 'グレビーシマウマ', scientific_name: 'Equus grevyi',
            taxon_class: TaxonClass.mammal, diet_type: DietType.herbivore,
            conservation_status: ConservationStatus.endangered,
            habitable_temperature_range: temp(8)..temp(40),
            lifespan_years: 20, maturity_age_years: 3, gestation_period_days: 390,
            adult_weight: Weight.from_kilograms(400),
            default_voice: 'ヒヒーン', group_living: true,
            litter_size: 1, charisma: 60
          )
        end

        def japanese_macaque
          Species.new(
            name_ja: 'ニホンザル', scientific_name: 'Macaca fuscata',
            taxon_class: TaxonClass.mammal, diet_type: DietType.omnivore,
            conservation_status: ConservationStatus.least_concern,
            habitable_temperature_range: temp(-15)..temp(32),
            lifespan_years: 25, maturity_age_years: 4, gestation_period_days: 170,
            adult_weight: Weight.from_kilograms(11),
            default_voice: 'キャッキャ', group_living: true,
            litter_size: 1, breeding_season: :autumn, charisma: 55
          )
        end

        def polar_bear
          Species.new(
            name_ja: 'ホッキョクグマ', scientific_name: 'Ursus maritimus',
            taxon_class: TaxonClass.mammal, diet_type: DietType.carnivore,
            conservation_status: ConservationStatus.vulnerable,
            habitable_temperature_range: temp(-40)..temp(15),
            lifespan_years: 25, maturity_age_years: 5, gestation_period_days: 240,
            adult_weight: Weight.from_kilograms(450),
            default_voice: 'ウゥー', group_living: false,
            litter_size: 2, charisma: 88
          )
        end

        def red_panda
          Species.new(
            name_ja: 'レッサーパンダ', scientific_name: 'Ailurus fulgens',
            taxon_class: TaxonClass.mammal, diet_type: DietType.herbivore,
            conservation_status: ConservationStatus.endangered,
            habitable_temperature_range: temp(-5)..temp(25),
            lifespan_years: 12, maturity_age_years: 2, gestation_period_days: 130,
            adult_weight: Weight.from_kilograms(5),
            default_voice: 'ピャー', group_living: false,
            litter_size: 2, charisma: 80
          )
        end

        def emperor_penguin
          Species.new(
            name_ja: 'コウテイペンギン', scientific_name: 'Aptenodytes forsteri',
            taxon_class: TaxonClass.bird, diet_type: DietType.piscivore,
            conservation_status: ConservationStatus.near_threatened,
            habitable_temperature_range: temp(-40)..temp(8),
            lifespan_years: 20, maturity_age_years: 4, gestation_period_days: 65,
            adult_weight: Weight.from_kilograms(30),
            default_voice: 'アー', group_living: true,
            litter_size: 1, charisma: 82
          )
        end

        def humboldt_penguin
          Species.new(
            name_ja: 'フンボルトペンギン', scientific_name: 'Spheniscus humboldti',
            taxon_class: TaxonClass.bird, diet_type: DietType.piscivore,
            conservation_status: ConservationStatus.vulnerable,
            habitable_temperature_range: temp(5)..temp(28),
            lifespan_years: 20, maturity_age_years: 2, gestation_period_days: 40,
            adult_weight: Weight.from_kilograms(4),
            default_voice: 'ガアガア', group_living: true,
            litter_size: 2, charisma: 70
          )
        end

        def red_crowned_crane
          Species.new(
            name_ja: 'タンチョウ', scientific_name: 'Grus japonensis',
            taxon_class: TaxonClass.bird, diet_type: DietType.omnivore,
            conservation_status: ConservationStatus.endangered,
            habitable_temperature_range: temp(-20)..temp(30),
            lifespan_years: 30, maturity_age_years: 3, gestation_period_days: 32,
            adult_weight: Weight.from_kilograms(9),
            default_voice: 'コォー', group_living: true,
            litter_size: 2, breeding_season: :spring, charisma: 65
          )
        end

        def burmese_python
          Species.new(
            name_ja: 'ビルマニシキヘビ', scientific_name: 'Python bivittatus',
            taxon_class: TaxonClass.reptile, diet_type: DietType.carnivore,
            conservation_status: ConservationStatus.vulnerable,
            habitable_temperature_range: temp(22)..temp(35),
            lifespan_years: 25, maturity_age_years: 3, gestation_period_days: 60,
            adult_weight: Weight.from_kilograms(75),
            default_voice: nil, group_living: false,
            litter_size: 20, charisma: 45
          )
        end

        def galapagos_tortoise
          Species.new(
            name_ja: 'ガラパゴスゾウガメ', scientific_name: 'Chelonoidis niger',
            taxon_class: TaxonClass.reptile, diet_type: DietType.herbivore,
            conservation_status: ConservationStatus.vulnerable,
            habitable_temperature_range: temp(20)..temp(35),
            lifespan_years: 100, maturity_age_years: 25, gestation_period_days: 130,
            adult_weight: Weight.from_kilograms(250),
            default_voice: nil, group_living: true,
            litter_size: 10, charisma: 50
          )
        end

        def japanese_fire_belly_newt
          Species.new(
            name_ja: 'アカハライモリ', scientific_name: 'Cynops pyrrhogaster',
            taxon_class: TaxonClass.amphibian, diet_type: DietType.insectivore,
            conservation_status: ConservationStatus.least_concern,
            habitable_temperature_range: temp(10)..temp(25),
            lifespan_years: 20, maturity_age_years: 3, gestation_period_days: 25,
            adult_weight: Weight.from_grams(15),
            default_voice: nil, group_living: true,
            litter_size: 200, charisma: 25
          )
        end

        def koi
          Species.new(
            name_ja: 'ニシキゴイ', scientific_name: 'Cyprinus rubrofuscus',
            taxon_class: TaxonClass.fish, diet_type: DietType.omnivore,
            conservation_status: ConservationStatus.least_concern,
            habitable_temperature_range: temp(2)..temp(30),
            lifespan_years: 35, maturity_age_years: 3, gestation_period_days: 7,
            adult_weight: Weight.from_kilograms(5),
            default_voice: nil, group_living: true,
            litter_size: 300, charisma: 30
          )
        end

        def hercules_beetle
          Species.new(
            name_ja: 'ヘラクレスオオカブト', scientific_name: 'Dynastes hercules',
            taxon_class: TaxonClass.invertebrate, diet_type: DietType.frugivore,
            conservation_status: ConservationStatus.least_concern,
            habitable_temperature_range: temp(18)..temp(28),
            lifespan_years: 2, maturity_age_years: 1, gestation_period_days: 35,
            adult_weight: Weight.from_grams(30),
            default_voice: nil, group_living: false,
            litter_size: 50, charisma: 40
          )
        end

        KEYS = %i[
          lion african_elephant reticulated_giraffe grevys_zebra japanese_macaque
          polar_bear red_panda emperor_penguin humboldt_penguin red_crowned_crane
          burmese_python galapagos_tortoise japanese_fire_belly_newt koi
          hercules_beetle
        ].freeze

        def keys
          KEYS
        end

        def all
          KEYS.map { |name| public_send(name) }
        end

        def find(key)
          symbol = key.to_s.to_sym
          return nil unless KEYS.include?(symbol)

          public_send(symbol)
        end
      end
    end
  end
end
