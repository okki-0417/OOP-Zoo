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
        @births = births
      end

      def conceive
        validate!
        @dam.conceive(inbreeding: coancestry(@sire, @dam))
        self
      end

      def related?
        sire_parents = parent_ids_of(@sire)
        dam_parents = parent_ids_of(@dam)
        dam_parents.include?(@sire.id) ||
          sire_parents.include?(@dam.id) ||
          sire_parents.intersect?(dam_parents)
      end

      def coancestry(a, b)
        return 0.0 if a.nil? || b.nil?
        return 0.5 * (1.0 + inbreeding_of(a)) if a.id == b.id
        return coancestry(b, a) if a.age_in_days > b.age_in_days

        parents = parents_of(a)
        return 0.0 if parents.empty?

        0.5 * parents.sum { |parent| coancestry(parent, b) }
      end

      def self.kinship(a, b, births)
        new(births:).coancestry(a, b)
      end

      def self.mean_kinship(animals, births)
        calc = new(births:)
        pairs = animals.combination(2).to_a
        return 0.0 if pairs.empty?

        pairs.sum { |a, b| calc.coancestry(a, b) } / pairs.size
      end

      private

      def validate!
        errors = []
        errors << 'sireはオスでなければなりません' unless @sire.male?
        errors << 'damはメスでなければなりません' unless @dam.female?
        errors << '同種でなければ繁殖できません' unless @sire.same_species?(@dam)
        errors << '異性でなければ繁殖できません' unless @sire.sex_opposite?(@dam)
        errors << '成熟な個体同士でなければ繁殖できません' unless @sire.fertile? && @dam.fertile?
        errors << '健康な個体同士でなければ繁殖できません' unless @sire.healthy? && @dam.healthy?
        errors << '近親交配は避ける必要があります' if related?
        errors << "#{@dam.species.name_ja}は#{@season.label}には繁殖しません" unless @dam.breeds_in?(@season)
        raise Errors::BreedingNotAllowed, errors.join(', ') unless errors.empty?
      end

      def parents_of(animal)
        @births.find { |birth| birth.offspring?(animal) }&.parents || []
      end

      def parent_ids_of(animal)
        parents_of(animal).map(&:id)
      end

      def inbreeding_of(animal)
        parents = parents_of(animal)
        return 0.0 if parents.size < 2

        coancestry(parents[0], parents[1])
      end
    end
  end
end
