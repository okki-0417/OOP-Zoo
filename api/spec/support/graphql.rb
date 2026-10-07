# frozen_string_literal: true

RSpec.configure do |config|
  config.include GraphQL::Testing::Helpers.for(OopZooSchema), file_path: %r{spec/graphql/types/}
end
