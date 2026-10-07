# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '繁殖の季節性' do
  def mate_in(species, season)
    sire = build(:animal, species: species)
    dam = build(:animal, :female, species: species)
    Breeding.new(sire:, dam:, day: 0, season:).conceive
  end

  describe '周年繁殖種' do
    it 'ライオンは季節を問わず周年で交配が成立すること' do
      expect { mate_in(SpeciesCatalog.lion, Season.summer) }.not_to raise_error
      expect { mate_in(SpeciesCatalog.lion, Season.winter) }.not_to raise_error
    end

    it 'ライオンは周年繁殖種であること' do
      expect(SpeciesCatalog.lion.breeds_year_round?).to be(true)
    end
  end

  describe '季節繁殖種' do
    it '季節繁殖種(ニホンザル)は自種の繁殖季節(秋)にのみ交配が成立すること' do
      expect { mate_in(SpeciesCatalog.japanese_macaque, Season.autumn) }.not_to raise_error
    end

    it '繁殖季節でない時期は、健康な成熟ペアでも交配が成立しないこと' do
      expect { mate_in(SpeciesCatalog.japanese_macaque, Season.spring) }
        .to raise_error(Errors::BreedingNotAllowed)
    end

    it '繁殖季節は種ごとに異なること(ニホンザルは秋、タンチョウは春)' do
      expect(SpeciesCatalog.japanese_macaque.breeding_season).to eq(:autumn)
      expect(SpeciesCatalog.red_crowned_crane.breeding_season).to eq(:spring)
    end
  end

  describe '季節性の表現' do
    it '各種は「周年」または特定の繁殖季節を持つこと' do
      expect(SpeciesCatalog.lion.breeds_year_round?).to be(true)
      expect(SpeciesCatalog.japanese_macaque.breeds_year_round?).to be(false)
    end

    it '繁殖季節は季節の巡り(Season.on_day)と連動して訪れ、その日のみ交配が成立すること' do
      expect(Season.on_day(200).value).to eq(:autumn)
      expect { mate_in(SpeciesCatalog.japanese_macaque, Season.on_day(200)) }.not_to raise_error
      expect { mate_in(SpeciesCatalog.japanese_macaque, Season.on_day(0)) }
        .to raise_error(Errors::BreedingNotAllowed)
    end
  end
end
