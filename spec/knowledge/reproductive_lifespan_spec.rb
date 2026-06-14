# frozen_string_literal: true

require 'spec_helper'

# 繁殖適齢期の知識。繁殖できるのは性成熟(下限)から高齢期(上限)までの窓に限られる。
# 高齢になると繁殖力が衰え(生殖の老化)、健康であっても繁殖できなくなる。
RSpec.describe '繁殖適齢期' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  sex     = Zoo::Domain::Animal::Sex

  # 健康で生きた、指定年齢のライオン(寿命15年)。
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
