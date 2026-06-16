# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '生殖の老化' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog

  def aged(species, years)
    Zoo::Domain::Animal.new(
      species: species, name: 'X', sex: Zoo::Domain::Animal::Sex.male,
      max_health: 100, age_in_days: 365 * years
    )
  end

  describe '生殖老化のある分類群' do
    it '哺乳類(ライオン)は高齢期(寿命15年の8割超=13歳)に、健康でも繁殖力が衰えること' do
      old_lion = aged(catalog.lion, 13)
      expect(old_lion).to be_alive
      expect(old_lion).not_to be_fertile
    end

    it '鳥類(タンチョウ)も高齢期(寿命30年の8割超=25歳)に繁殖力が衰えること' do
      old_crane = aged(catalog.red_crowned_crane, 25)
      expect(old_crane).to be_alive
      expect(old_crane).not_to be_fertile
    end
  end

  describe '終生繁殖する分類群' do
    it '爬虫類(ガラパゴスゾウガメ)は高齢(寿命100年のうち90歳)でも繁殖しうること' do
      old_tortoise = aged(catalog.galapagos_tortoise, 90)
      expect(old_tortoise).to be_fertile
    end

    it '魚類(ニシキゴイ)は高齢(寿命35年のうち30歳)でも繁殖しうること' do
      old_koi = aged(catalog.koi, 30)
      expect(old_koi).to be_fertile
    end
  end

  describe '老化の表現' do
    it '生殖老化の有無は種(分類群)ごとに定まること' do
      expect(catalog.lion.reproductively_senesces?).to be(true)
      expect(catalog.red_crowned_crane.reproductively_senesces?).to be(true)
      expect(catalog.galapagos_tortoise.reproductively_senesces?).to be(false)
      expect(catalog.koi.reproductively_senesces?).to be(false)
    end
  end
end
