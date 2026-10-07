# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Alert do
  it 'subjectId・subjectName は園が対象のとき nil・園の名前を返すこと' do
    alert = { severity: :critical, kind: :insolvent, subject_type: :zoo, subject: build(:zoo, name: 'OOP動物園'),
              message: '資金が尽きました' }

    expect(run_graphql_field('Alert.subjectId', alert)).to be_nil
    expect(run_graphql_field('Alert.subjectName', alert)).to eq('OOP動物園')
  end

  it 'subjectId・subjectName はエリアが対象のとき そのエリアの id・名前を返すこと' do
    hill = create(:enclosure, name: 'ライオンの丘')
    alert = { severity: :warning, kind: :unassigned, subject_type: :enclosure, subject: hill, message: '担当がいません' }

    expect(run_graphql_field('Alert.subjectId', alert)).to eq(hill.id)
    expect(run_graphql_field('Alert.subjectName', alert)).to eq('ライオンの丘')
  end

  it 'severity・kind・subjectType は :warning・:unassigned・:enclosure を WARNING・UNASSIGNED・ENCLOSURE として出せること' do
    expect(Types::AlertSeverity.coerce_isolated_result(:warning)).to eq('WARNING')
    expect(Types::AlertKind.coerce_isolated_result(:unassigned)).to eq('UNASSIGNED')
    expect(Types::AlertSubject.coerce_isolated_result(:enclosure)).to eq('ENCLOSURE')
  end
end
