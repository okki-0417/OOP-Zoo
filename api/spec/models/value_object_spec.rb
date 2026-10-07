# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ValueObject do
  describe '#==' do
    context '#components を実装していないとき' do
      let(:klass) { Class.new { include ValueObject } }

      it 'NotImplementedError を投げること' do
        expect { klass.new == klass.new }.to raise_error(NotImplementedError)
      end
    end
  end
end
