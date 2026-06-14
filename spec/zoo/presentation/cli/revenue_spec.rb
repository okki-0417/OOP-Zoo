# frozen_string_literal: true

require 'spec_helper'
require 'stringio'

RSpec.describe Zoo::Presentation::Cli::Revenue do
  let(:container) { Zoo::Composition::Container.new }
  let(:output) { StringIO.new }
  let(:handler) { described_class.new(container: container, output: output) }

  describe '#run' do
    it '来園前は累計収益 ¥0 を表示すること' do
      handler.run([])

      expect(output.string).to include('累計収益: ¥0')
    end

    it '来園者受け入れ後は累計収益を反映して表示すること' do
      container.admit_visitors.call(Zoo::Application::Commands::AdmitVisitorsCommand.new(count: 10))

      handler.run([])

      expect(output.string).to include('累計収益: ¥20,000')
    end
  end
end
