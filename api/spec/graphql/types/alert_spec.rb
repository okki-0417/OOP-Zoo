# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Alert do
  let(:alert) { { severity: :warning, kind: :unassigned, subject_type:, subject: target, message: '担当がいません' } }
  let(:subject_type) { :enclosure }
  let(:target) { create(:enclosure, name: 'ライオンの丘') }

  describe 'subjectId' do
    context '対象がエリアのとき' do
      it 'そのエリアの id を返すこと' do
        expect(run_graphql_field('Alert.subjectId', alert)).to eq(target.id)
      end
    end

    context '対象が園のとき' do
      let(:subject_type) { :zoo }
      let(:target) { build(:zoo, name: 'OOP動物園') }

      it 'nil を返すこと' do
        expect(run_graphql_field('Alert.subjectId', alert)).to be_nil
      end
    end
  end

  describe 'subjectName' do
    context '対象がエリアのとき' do
      it 'エリアの名前 "ライオンの丘" を返すこと' do
        expect(run_graphql_field('Alert.subjectName', alert)).to eq('ライオンの丘')
      end
    end

    context '対象が園のとき' do
      let(:subject_type) { :zoo }
      let(:target) { build(:zoo, name: 'OOP動物園') }

      it '園の名前 "OOP動物園" を返すこと' do
        expect(run_graphql_field('Alert.subjectName', alert)).to eq('OOP動物園')
      end
    end
  end

  describe 'severity・kind・subjectType' do
    it ':warning・:unassigned・:enclosure を WARNING・UNASSIGNED・ENCLOSURE として出せること' do
      expect(Types::AlertSeverity.coerce_isolated_result(:warning)).to eq('WARNING')
      expect(Types::AlertKind.coerce_isolated_result(:unassigned)).to eq('UNASSIGNED')
      expect(Types::AlertSubject.coerce_isolated_result(:enclosure)).to eq('ENCLOSURE')
    end
  end
end
