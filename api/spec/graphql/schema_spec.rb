# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OopZooSchema do
  describe '.to_definition' do
    it 'リポジトリ直下の schema.graphql と一致すること(ずれたら bin/dump-graphql-schema を実行する)' do
      expect(Rails.root.join('../schema.graphql').read).to eq(described_class.to_definition)
    end
  end
end
