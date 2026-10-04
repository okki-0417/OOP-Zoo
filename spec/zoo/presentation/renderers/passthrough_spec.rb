# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Presentation::Renderers::Passthrough do
  describe '.render' do
    it 'success の Result を渡すと同じ Result をそのまま返すこと' do
      result = Zoo::Application::Result.success(:revenue, 1)

      expect(described_class.render(result)).to be(result)
    end

    it 'failure の Result を渡しても同じ Result をそのまま返すこと' do
      result = Zoo::Application::Result.failure(:animal_detail, Zoo::Application::Errors::AnimalNotFound.new('x'))

      expect(described_class.render(result)).to be(result)
    end
  end
end
