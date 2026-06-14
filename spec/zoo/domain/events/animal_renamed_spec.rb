# frozen_string_literal: true

require 'spec_helper'

module Zoo
  module Domain
    module Events
      RSpec.describe AnimalRenamed do
        it '旧名・新名を保持すること' do
          event = described_class.new(animal: :a, old_name: 'Jack', new_name: 'Cat')
          expect(event.old_name).to eq('Jack')
          expect(event.new_name).to eq('Cat')
        end

        it '#to_s は 改名の説明文を返すこと' do
          event = described_class.new(animal: :a, old_name: 'Jack', new_name: 'Cat')
          expect(event.to_s).to eq('「Jack」を「Cat」に改名しました')
        end
      end
    end
  end
end
