# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Presentation::Graphql::Schema do
  it 'リポジトリ直下の schema.graphql が Schema.to_definition と一致すること(ずれたら bin/dump-graphql-schema を実行する)' do
    dumped = File.read(File.expand_path('../../../../../schema.graphql', __dir__))

    expect(dumped).to eq(described_class.to_definition)
  end
end
