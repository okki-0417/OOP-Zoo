# frozen_string_literal: true

require 'spec_helper'

# リポジトリポート(抽象インターフェース)の契約。未実装のまま呼ぶと
# NotImplementedError を送出し、実装漏れを早期に知らせる。
module Zoo
  module Domain
    module Repositories
      RSpec.describe 'リポジトリポートの未実装契約' do
        # 各ポートを include しただけの空実装。
        def adapter_including(port)
          Class.new { include port }.new
        end

        it 'AnimalRepository#find / #save は未実装だと NotImplementedError' do
          adapter = adapter_including(AnimalRepository)
          expect { adapter.find('x') }.to raise_error(NotImplementedError)
          expect { adapter.save(:a) }.to raise_error(NotImplementedError)
        end

        it 'EnclosureRepository#find / #save / #all は未実装だと NotImplementedError' do
          adapter = adapter_including(EnclosureRepository)
          expect { adapter.find('x') }.to raise_error(NotImplementedError)
          expect { adapter.save(:e) }.to raise_error(NotImplementedError)
          expect { adapter.all }.to raise_error(NotImplementedError)
        end

        it 'KeeperRepository#find / #save / #all は未実装だと NotImplementedError' do
          adapter = adapter_including(KeeperRepository)
          expect { adapter.find('x') }.to raise_error(NotImplementedError)
          expect { adapter.save(:k) }.to raise_error(NotImplementedError)
          expect { adapter.all }.to raise_error(NotImplementedError)
        end

        it 'VeterinarianRepository#find / #save / #all は未実装だと NotImplementedError' do
          adapter = adapter_including(VeterinarianRepository)
          expect { adapter.find('x') }.to raise_error(NotImplementedError)
          expect { adapter.save(:v) }.to raise_error(NotImplementedError)
          expect { adapter.all }.to raise_error(NotImplementedError)
        end

        it 'ZooRepository#load / #save は未実装だと NotImplementedError' do
          adapter = adapter_including(ZooRepository)
          expect { adapter.load }.to raise_error(NotImplementedError)
          expect { adapter.save(:z) }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end
