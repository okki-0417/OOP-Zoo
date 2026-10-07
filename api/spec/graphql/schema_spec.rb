# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OopZooSchema do
  it 'リポジトリ直下の schema.graphql が Schema.to_definition と一致すること(ずれたら bin/dump-graphql-schema を実行する)' do
    dumped = Rails.root.join('../schema.graphql').read

    expect(dumped).to eq(described_class.to_definition)
  end
end
