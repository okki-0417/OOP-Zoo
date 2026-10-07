# frozen_string_literal: true

module Services
  module Commands
    MakeRoundsCommand = Data.define(:keeper_id) do
      def initialize(keeper_id:)
        raise ArgumentError, 'keeper_id は必須です' if keeper_id.nil?

        super
      end
    end
  end
end
