# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Domain::Animal do
  describe '#cry_out' do
    let(:animal) { described_class.new(species: 'Dog', name: 'Jack', voice: 'Woof', max_health: max_health) }
    let(:max_health) { 10 }

    it '定義された音を返すこと' do
      expect(animal.cry_out).to eq('Woof')
    end

    it '鳴き声が空文字の場合は"..."を返すこと' do
      animal.change_voice('')
      expect(animal.cry_out).to eq('...')
    end

    it '鳴き声がnilの場合は"..."を返すこと' do
      silent = described_class.new(species: 'Dog', name: 'Silent', voice: nil, max_health: max_health)
      expect(silent.cry_out).to eq('...')
    end

    it '鳴くと体力が1減ること' do
      expect { animal.cry_out }.to change { animal.current_health }.by(-1)
    end

    it '体力が20%以下のときは弱い音を返すこと' do
      (max_health * 0.8).to_i.times { animal.cry_out }
      expect(animal.cry_out).to eq('Woof...')
    end

    it '体力が0のときは"..."を返すこと' do
      max_health.times { animal.cry_out }
      expect(animal.cry_out).to eq('...')
    end
  end

  describe '#change_voice' do
    let(:animal) { described_class.new(species: 'Dog', name: 'Jack', voice: 'Woof', max_health: 10) }

    it '音を変更できること' do
      animal.change_voice('Meow')
      expect(animal.cry_out).to eq('Meow')
    end

    it '空の文字列に変更できること' do
      expect { animal.change_voice('') }.not_to raise_error
    end

    it 'nilには変更できないこと' do
      expect { animal.change_voice(nil) }.to raise_error(ArgumentError)
    end
  end

  describe '#heal' do
    let(:animal) { described_class.new(species: 'Dog', name: 'Jack', voice: 'Woof', max_health: 10) }

    before do
      5.times { animal.cry_out }
    end

    it '自分を回復できること' do
      expect { animal.heal(3) }.to change { animal.current_health }.by(3)
    end

    it '最大体力を回復しても最大体力を超えないこと' do
      animal.heal(10)
      expect(animal.current_health).to eq(10)
    end

    it '最大体力の時は回復しても体力が変わらないこと' do
      animal.heal(10)
      expect { animal.heal(5) }.not_to(change { animal.current_health })
    end

    it '回復した後の体力の値を返すこと' do
      expect(animal.heal(3)).to eq(8)
    end

    it 'マイナスの回復量が与えられたときはエラーになること' do
      expect { animal.heal(-1) }.to raise_error(ArgumentError)
    end

    it '0の回復量が与えられたときは体力が変わらないこと' do
      expect { animal.heal(0) }.not_to(change { animal.current_health })
    end
  end

  describe '#change_name' do
    let(:animal) { described_class.new(species: 'Dog', name: 'Jack', voice: 'Woof', max_health: 10) }

    it '名前がnilだとエラーになること' do
      expect { animal.change_name(nil) }.to raise_error(ArgumentError)
    end

    it '名前が空文字だとエラーになること' do
      expect { animal.change_name('') }.to raise_error(ArgumentError)
    end

    it '名前を変更できること' do
      animal.change_name('Cat')
      expect(animal.name).to eq('Cat')
    end
  end
end
