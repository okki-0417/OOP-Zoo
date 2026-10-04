const yenFormat = new Intl.NumberFormat("ja-JP", { style: "currency", currency: "JPY" });

export const yen = (amount: number) => yenFormat.format(amount);

export const percent = (value: number, max: number) =>
  max <= 0 ? 0 : Math.max(0, Math.min(100, Math.round((value / max) * 100)));

const classEmoji: Record<string, string> = {
  哺乳類: "🦁",
  鳥類: "🐧",
  爬虫類: "🐢",
  両生類: "🦎",
  魚類: "🐟",
  無脊椎動物: "🪲",
};

const speciesEmoji: Record<string, string> = {
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
  speciesEmoji[species] ?? (taxonClass && classEmoji[taxonClass]) ?? "🐾";
