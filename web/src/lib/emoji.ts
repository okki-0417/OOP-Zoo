const byTaxonClass: Record<string, string> = {
  哺乳類: "🦁",
  鳥類: "🐧",
  爬虫類: "🐢",
  両生類: "🦎",
  魚類: "🐟",
  無脊椎動物: "🪲",
};

const bySpecies: Record<string, string> = {
  ライオン: "🦁",
  アフリカゾウ: "🐘",
  アミメキリン: "🦒",
  グレビーシマウマ: "🦓",
  ニホンザル: "🐒",
  ホッキョクグマ: "🐻‍❄️",
  レッサーパンダ: "🦝",
  コウテイペンギン: "🐧",
  フンボルトペンギン: "🐧",
  タンチョウ: "🕊️",
  ビルマニシキヘビ: "🐍",
  ガラパゴスゾウガメ: "🐢",
  アカハライモリ: "🦎",
  ニシキゴイ: "🐟",
  ヘラクレスオオカブト: "🪲",
};

export const emojiOf = (species: string, taxonClass?: string) =>
  bySpecies[species] ?? (taxonClass && byTaxonClass[taxonClass]) ?? "🐾";
