# frozen_string_literal: true

module Zoo
  module Domain
    module Staff
      # 飼育員を表すエンティティ。
      #
      # 担当できる分類群(綱)に専門性を持ち、専門外の動物には給餌できない。
      # 給餌・清掃・エリア担当を通じて飼育エリアと動物の世話をする。
      class Keeper
        attr_reader :id, :name, :specialties

        # specialties: 担当できる TaxonClass の配列。
        def initialize(name:, specialties:, id: Shared::Identifier.new)
          raise ArgumentError, '飼育員名は必須です' if name.to_s.empty?
          raise ArgumentError, '専門分野を1つ以上指定してください' if specialties.nil? || specialties.empty?

          @id = id
          @name = name
          @specialties = specialties
          @assigned_enclosures = []
        end

        # この動物を担当できるか(綱が専門に含まれるか)。
        def qualified_for?(animal)
          @specialties.include?(animal.species.taxon_class)
        end

        # 動物に給餌する。専門外の動物には給餌できない。
        def feed(animal, food)
          ensure_qualified!(animal)
          animal.eat(food)
          self
        end

        # 担当エリアを割り当てる。
        def assign_to(enclosure)
          @assigned_enclosures << enclosure unless @assigned_enclosures.include?(enclosure)
          self
        end

        def assigned_enclosures
          @assigned_enclosures.dup
        end

        # エリアを清掃する。
        def clean(enclosure, amount = 100)
          enclosure.clean(amount)
          self
        end

        def to_s
          "飼育員 #{@name}(#{@specialties.map(&:label).join('・')}担当)"
        end

        private

        def ensure_qualified!(animal)
          return if qualified_for?(animal)

          raise Errors::NotQualified,
                "飼育員#{@name}は#{animal.species.taxon_class.label}を担当できません"
        end
      end
    end
  end
end
