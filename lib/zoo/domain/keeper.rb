# frozen_string_literal: true

module Zoo
  module Domain
    class Keeper
      include Shared::Entity

      attr_reader :id, :name, :specialties

      def initialize(name:, specialties:, id: Shared::Identifier.new)
        raise ArgumentError, '飼育員名は必須です' if name.to_s.empty?
        raise ArgumentError, '専門分野を1つ以上指定してください' if specialties.nil? || specialties.empty?

        @id = id
        @name = name
        @specialties = specialties
      end

      def self.reconstitute(id:, name:, specialties:)
        allocate.tap do |keeper|
          keeper.instance_variable_set(:@id, id)
          keeper.instance_variable_set(:@name, name)
          keeper.instance_variable_set(:@specialties, specialties)
        end
      end

      def specialized_in?(taxon_class)
        @specialties.include?(taxon_class)
      end

      def specialties_label
        @specialties.map(&:label).join('・')
      end

      def to_s
        "飼育員 #{@name}(#{specialties_label}担当)"
      end
    end
  end
end
