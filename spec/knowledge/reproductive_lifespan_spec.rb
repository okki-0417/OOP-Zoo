# frozen_string_literal: true

require 'spec_helper'

RSpec.describe '繁殖適齢期' do
  def lion_aged(years)
    Zoo::Domain::Animal.new(
      species: Zoo::Domain::Taxonomy::SpeciesCatalog.lion,
      name: 'X', sex: Zoo::Domain::Animal::Sex.male, max_health: 100, age_in_days: 365 * years
    )
  end

  context '性成熟前(2歳の幼体)のとき' do
    it 'まだ繁殖できないこと' do
      expect(lion_aged(2)).not_to be_fertile
    end
  end

  context '適齢期(5歳)のとき' do
    it '繁殖できること' do
      expect(lion_aged(5)).to be_fertile
    end
  end

  context '高齢期(寿命15年の8割=12年を超えた13歳)のとき' do
    it '健康であっても生殖の老化で繁殖できないこと' do
      old = lion_aged(13)
      expect(old).to be_alive
      expect(old).not_to be_fertile
    end
  end
end
