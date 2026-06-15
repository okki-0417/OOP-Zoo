# frozen_string_literal: true

require 'spec_helper'

# 繁殖の季節性の知識。繁殖期は種ごとに異なり、季節を持たず周年繁殖する種もいれば、
# 特定の季節(発情期)にしか交配しない季節繁殖種もいる。
RSpec.describe '繁殖の季節性' do
  catalog  = Zoo::Domain::Taxonomy::SpeciesCatalog
  season   = Zoo::Domain::Operations::Season
  calendar = Zoo::Domain::Operations::Calendar
  errors   = Zoo::Domain::Errors

  def pair_of(species)
    sire, dam = build_pair(species)
    Zoo::Domain::Breeding::BreedingPair.new(sire: sire, dam: dam)
  end

  describe '周年繁殖種' do
    it 'ライオンは季節を問わず周年で交配が成立すること' do
      expect { pair_of(catalog.lion).mate(season: season.summer) }.not_to raise_error
      expect { pair_of(catalog.lion).mate(season: season.winter) }.not_to raise_error
    end

    it 'ライオンは周年繁殖種であること' do
      expect(catalog.lion.breeds_year_round?).to be(true)
    end
  end

  describe '季節繁殖種' do
    it '季節繁殖種(ニホンザル)は自種の繁殖季節(秋)にのみ交配が成立すること' do
      expect { pair_of(catalog.japanese_macaque).mate(season: season.autumn) }.not_to raise_error
    end

    it '繁殖季節でない時期は、健康な成熟ペアでも交配が成立しないこと' do
      expect { pair_of(catalog.japanese_macaque).mate(season: season.spring) }
        .to raise_error(errors::BreedingNotAllowed)
    end

    it '繁殖季節は種ごとに異なること(ニホンザルは秋、タンチョウは春)' do
      expect(catalog.japanese_macaque.breeding_season).to eq(:autumn)
      expect(catalog.red_crowned_crane.breeding_season).to eq(:spring)
    end
  end

  describe '季節性の表現' do
    it '各種は「周年」または特定の繁殖季節を持つこと' do
      expect(catalog.lion.breeds_year_round?).to be(true)
      expect(catalog.japanese_macaque.breeds_year_round?).to be(false)
    end

    it '繁殖季節は季節の巡り(Calendar)と連動して訪れること' do
      autumn_day = calendar.season_for(200) # 200日目は秋
      expect(autumn_day.value).to eq(:autumn)
      expect(catalog.japanese_macaque.breeds_in?(autumn_day)).to be(true)
      expect(catalog.japanese_macaque.breeds_in?(calendar.season_for(0))).to be(false) # 春
    end
  end
end
