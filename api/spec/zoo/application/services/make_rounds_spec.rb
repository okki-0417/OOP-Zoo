# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Zoo::Application::Services::MakeRounds do
  catalog = Zoo::Domain::SpeciesCatalog

  let!(:keeper) { build_keeper(Zoo::Domain::TaxonClass.mammal).tap(&:save!) }
  let!(:hill) { create_enclosure(celsius: 24) }
  let!(:leo) { build_adult(catalog.lion, name: 'レオ').get_hungrier(60).move_to(hill).tap(&:save!) }

  def make_rounds(keeper_id: keeper.id)
    described_class.new(command: Zoo::Application::Commands::MakeRoundsCommand.new(keeper_id:)).call
  end

  describe '#call' do
    context '飼育員がライオンの丘を担当しているとき' do
      before { keeper.enclosures << hill }

      it '担当エリアを見回ってレオに給餌し、給餌した個体と残り勤務時間(470分)の飼育員を返すこと' do
        view = make_rounds.value

        expect(view[:keeper]).to have_attributes(name: '飼育員', remaining_minutes: 470)
        expect(view[:reports].map(&:enclosure)).to eq([hill])
        expect(view[:reports].first.fed.map(&:name)).to eq(['レオ'])
      end

      it '給餌した個体と勤務時間を使った飼育員を保存すること' do
        make_rounds

        expect(leo.reload.hunger_level).to eq(0)
        expect(keeper.reload.worked_minutes).to eq(10)
      end
    end

    it '担当エリアがなければ reports は空で、勤務時間も使わないこと' do
      view = make_rounds.value

      expect(view[:reports]).to eq([])
      expect(view[:keeper].remaining_minutes).to eq(480)
    end

    it "存在しない keeper_id 'missing' は KeeperNotFound の失敗 Result を返すこと" do
      expect(make_rounds(keeper_id: 'missing').error).to be_a(Zoo::Application::Errors::KeeperNotFound)
    end
  end
end
