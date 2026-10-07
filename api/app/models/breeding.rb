# frozen_string_literal: true

class Breeding < ApplicationRecord
  belongs_to :sire, class_name: 'Animal'
  belongs_to :dam, class_name: 'Animal'

  attribute :season, ValueType.new(Season, dump: ->(season) { season.value.to_s }),
            default: -> { Season.spring }
  attribute :day, default: 0

  def self.latest_of(dam)
    where(dam:).order(:id).last
  end

  def conceive
    validate_pairing!
    dam.conceive(inbreeding: pedigree.coancestry(sire, dam))
    self
  end

  private

  def validate_pairing!
    errors = []
    errors << 'sireはオスでなければなりません' unless sire.male?
    errors << 'damはメスでなければなりません' unless dam.female?
    errors << '同種でなければ繁殖できません' unless sire.species == dam.species
    errors << '成熟な個体同士でなければ繁殖できません' unless sire.fertile? && dam.fertile?
    errors << '健康な個体同士でなければ繁殖できません' unless sire.healthy? && dam.healthy?
    errors << '近親交配は避ける必要があります' if pedigree.related?(sire, dam)
    out_of_season = dam.female? && !Estrus.new(dam, season).active?
    errors << "#{dam.species_name}は#{season.label}には繁殖しません" if out_of_season
    raise Errors::BreedingNotAllowed, errors.join(', ') unless errors.empty?
  end

  def pedigree
    @pedigree ||= Pedigree.new
  end
end
