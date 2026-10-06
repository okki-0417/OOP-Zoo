# frozen_string_literal: true

Rails.application.config.to_prepare do
  next if Rails.env.test?

  database = Rails.configuration.x.zoo_database
  FileUtils.mkdir_p(File.dirname(database))
  Rails.configuration.x.zoo_container = Zoo::Composition::Container.new(database:)
end
