# frozen_string_literal: true

module Zoo
  module Domain
    class Breeding
      include Shared::Entity

      attr_reader :id, :sire, :dam, :day, :season

      def initialize(sire: nil, dam: nil, day: 0, season: Season.spring, births: [], id: Shared::Identifier.new)
        @id = id
        @sire = sire
        @dam = dam
        @day = day
        @season = season
        @pedigree = Pedigree.new(births)
      end

      def conceive
        validate!
        @dam.conceive(inbreeding: @pedigree.coancestry(@sire, @dam))
        self
      end

      private

      def validate!
        errors = []
        errors << 'sireはオスでなければなりません' unless @sire.male?
        errors << 'damはメスでなければなりません' unless @dam.female?
        errors << '同種でなければ繁殖できません' unless @sire.species == @dam.species
        errors << '成熟な個体同士でなければ繁殖できません' unless @sire.fertile? && @dam.fertile?
        errors << '健康な個体同士でなければ繁殖できません' unless @sire.healthy? && @dam.healthy?
        errors << '近親交配は避ける必要があります' if @pedigree.related?(@sire, @dam)
        out_of_season = @dam.female? && !Estrus.new(@dam, @season).active?
        errors << "#{@dam.species.name_ja}は#{@season.label}には繁殖しません" if out_of_season
        raise Errors::BreedingNotAllowed, errors.join(', ') unless errors.empty?
      end
    end
  end
end
