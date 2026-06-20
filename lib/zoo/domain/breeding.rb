# frozen_string_literal: true

module Zoo
  module Domain
    class Breeding
      include Shared::Entity

      attr_reader :id, :sire, :dam, :day, :season

      def initialize(sire:, dam:, day: 0, season: Season.spring, parents: [], id: Shared::Identifier.new)
        @id = id
        @sire = sire
        @dam = dam
        @day = day
        @season = season
        @parent_lookup = parents.to_h { |a| [a.id, a] }
      end

      def conceive
        validate!
        @dam.conceive(inbreeding: inbreeding_coefficient)
        self
      end

      def related?
        @dam.parent_ids.include?(@sire.id) ||
          @sire.parent_ids.include?(@dam.id) ||
          @sire.parent_ids.intersect?(@dam.parent_ids)
      end

      def self.mean_kinship(animals, parents)
        lookup = parents.to_h { |a| [a.id, a] }
        pairs = animals.combination(2).to_a
        return 0.0 if pairs.empty?

        pairs.sum { |a, b| compute_kinship(a, b, lookup) } / pairs.size
      end

      def self.kinship(a, b, parents)
        compute_kinship(a, b, parents.to_h { |a| [a.id, a] })
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

      def inbreeding_coefficient
        self.class.send(:compute_kinship, @sire, @dam, @parent_lookup)
      end

      class << self
        private

        def compute_kinship(a, b, lookup)
          return 0.0 if a.nil? || b.nil?
          return 0.5 * (1.0 + compute_inbreeding(a, lookup)) if a.id == b.id
          return compute_kinship(b, a, lookup) if a.age_in_days > b.age_in_days

          parents = a.parent_ids.map { |id| lookup[id] }.compact
          return 0.0 if parents.empty?

          0.5 * parents.sum { |parent| compute_kinship(parent, b, lookup) }
        end

        def compute_inbreeding(animal, lookup)
          parents = animal.parent_ids.map { |id| lookup[id] }.compact
          return 0.0 if parents.size < 2

          compute_kinship(parents[0], parents[1], lookup)
        end
      end
    end
  end
end
