// 表示用の装飾だけを集めた定数（ドメインの複製ではない）。種名/保全コードは
// サーバ由来の値で引く。未知のキーは無難なフォールバックにする。

const SPECIES_EMOJI: Record<string, string> = {
  ライオン: '🦁',
  アフリカゾウ: '🐘',
  アミメキリン: '🦒',
  グレビーシマウマ: '🦓',
  ニホンザル: '🐒',
  ホッキョクグマ: '🐻‍❄️',
  レッサーパンダ: '🦝',
  コウテイペンギン: '🐧',
  フンボルトペンギン: '🐧',
  タンチョウ: '🐦',
  ビルマニシキヘビ: '🐍',
  ガラパゴスゾウガメ: '🐢',
  アカハライモリ: '🦎',
  ニシキゴイ: '🐟',
  ヘラクレスオオカブト: '🪲',
}

export const speciesEmoji = (nameJa: string): string => SPECIES_EMOJI[nameJa] ?? '🐾'

const CONSERVATION_COLOR: Record<string, string> = {
  LC: '#6cc070', NT: '#9ec06a', VU: '#e0b14a',
  EN: '#e08a3c', CR: '#e5736b', EW: '#b06bd0', EX: '#8a99a6',
}

export const conservationColor = (code: string): string => CONSERVATION_COLOR[code] ?? '#8a99a6'

export const ratioColor = (ratio: number): string =>
  ratio > 0.5 ? '#6cc070' : ratio > 0.25 ? '#e0b14a' : '#e5736b'
