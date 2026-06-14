# frozen_string_literal: true

require 'spec_helper'

# 繁殖期の知識。多くの動物には繁殖の季節があり、本園では春を繁殖期とする。
# 繁殖期でない季節には交配が成立しない。
RSpec.describe '繁殖期' do
  catalog = Zoo::Domain::Taxonomy::SpeciesCatalog
  season  = Zoo::Domain::Operations::Season
  errors  = Zoo::Domain::Errors

  def pair
    Zoo::Domain::Breeding::BreedingPair.new(
      sire: build_adult(Zoo::Domain::Taxonomy::SpeciesCatalog.lion, name: '父', sex: Zoo::Domain::Animal::Sex.male),
      dam: build_adult(Zoo::Domain::Taxonomy::SpeciesCatalog.lion, name: '母', sex: Zoo::Domain::Animal::Sex.female)
    )
  end

  context '繁殖期(春)に交配すると' do
    it '交配が成立すること' do
      expect { pair.mate(season: season.spring) }.not_to raise_error
    end
  end

  context '繁殖期でない季節(夏)に交配しようとすると' do
    it '繁殖できないこと' do
      expect { pair.mate(season: season.summer) }.to raise_error(errors::BreedingNotAllowed)
    end
  end
end
