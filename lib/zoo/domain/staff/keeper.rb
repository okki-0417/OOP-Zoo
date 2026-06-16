# frozen_string_literal: true

module Zoo
  module Domain
    module Staff
      class Keeper
        include Shared::Entity

        attr_reader :id, :name, :specialties

        def initialize(name:, specialties:, id: Shared::Identifier.new)
          raise ArgumentError, '飼育員名は必須です' if name.to_s.empty?
          raise ArgumentError, '専門分野を1つ以上指定してください' if specialties.nil? || specialties.empty?

          @id = id
          @name = name
          @specialties = specialties
          @assigned_enclosures = []
        end

        def self.reconstitute(id:, name:, specialties:)
          allocate.tap do |keeper|
            keeper.instance_variable_set(:@id, id)
            keeper.instance_variable_set(:@name, name)
            keeper.instance_variable_set(:@specialties, specialties)
            keeper.instance_variable_set(:@assigned_enclosures, [])
          end
        end

        def qualified_for?(animal)
          @specialties.include?(animal.species.taxon_class)
        end

        def feed(animal, food)
          ensure_qualified!(animal)
          animal.eat(food)
          self
        end

        def assign_to(enclosure)
          @assigned_enclosures << enclosure unless @assigned_enclosures.include?(enclosure)
          self
        end

        def assigned_enclosures
          @assigned_enclosures.dup
        end

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
