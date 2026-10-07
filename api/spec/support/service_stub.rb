# frozen_string_literal: true

module ServiceStub
  def stub_service(use_case, result)
    service_class = Services.const_get(use_case.to_s.camelize)
    allow(service_class).to receive(:new).and_return(instance_double(service_class, call: result))
    service_class
  end
end

RSpec.configure do |config|
  config.include ServiceStub, file_path: %r{spec/graphql/mutations/}
end
