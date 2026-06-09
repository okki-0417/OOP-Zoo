# 動物園ドメインモデル

現実の動物園をリッチに再現することを目的とした、ドメイン駆動設計(DDD)のドメイン層。
プレゼンテーション層・データソース層は持たず、ドメインの語彙と振る舞いだけで構成する。

すべて `Zoo::Domain` 名前空間の下にあり、`zeitwerk` で自動読み込みされる。
テストは `./bin/test`(内部で rspec を起動)で実行する。

## ユビキタス言語(Ubiquitous Language)

| 用語 | クラス | 意味 |
| --- | --- | --- |
| 動物個体 | `Animal` | 種を参照する固有の存在。体力・空腹・年齢・生死を持つ集約ルート |
| 種 | `Taxonomy::Species` | 和名・学名・綱・食性・保全状況・生態情報を持つ不変の分類情報 |
| 綱 | `Taxonomy::TaxonClass` | 哺乳類/鳥類/爬虫類/両生類/魚類/無脊椎。恒温・胎生などの性質を導く |
| 食性 | `Taxonomy::DietType` | 肉食/魚食/昆虫食/草食/果実食/雑食。食べられる餌カテゴリを定義 |
| 保全状況 | `Taxonomy::ConservationStatus` | IUCNレッドリスト(LC〜EX)。深刻度に順序を持つ |
| 飼育エリア | `Husbandry::Enclosure` | 動物を収容する集約。定員・気候・清潔度・同居相性を管理 |
| 同居ポリシー | `Husbandry::CohabitationPolicy` | 2種を同居させてよいかを判断するドメインサービス |
| 餌 | `Feeding::Food` | カテゴリと満腹度を持つ値オブジェクト |
| 飼育員 | `Staff::Keeper` | 専門の綱を担当し、給餌・清掃を行う |
| 獣医 | `Staff::Veterinarian` | 診察・治療を行う |
| 病気 | `Medical::Illness` | 毎日体力を削り、感染しうる |
| 繁殖ペア | `Breeding::BreedingPair` | 雌雄一組。交尾→妊娠/抱卵→出産/孵化を管理 |
| 繁殖ポリシー | `Breeding::BreedingPolicy` | 近親交配の回避など繁殖可否を判断 |
| 動物園 | `Zoo` | 全エリア・職員・収益・来園者を束ねる最上位の集約ルート |

## 区切られた文脈(Bounded Contexts)

- **Shared** — 文脈横断の値オブジェクト(`Health` 体力 / `Hunger` 空腹度 / `Weight` 体重 /
  `Temperature` 気温 / `Sex` 性別 / `LifeStage` ライフステージ / `Cleanliness` 清潔度 /
  `Money` 金額 / `Identifier` 識別子)と、値オブジェクトの等価性 mixin `ValueObject`。
- **Taxonomy(分類)** — 種とその分類・生態。`SpeciesCatalog` に実在15種を収録(全6綱・全6食性を網羅)。
- **Husbandry(飼育)** — 飼育エリアと同居ポリシー。
- **Feeding(給餌)** — 餌と食性整合。`FoodCatalog` に代表的な餌を収録。
- **Medical(医療)** — 病気と治療。`IllnessCatalog` に代表的な疾病を収録。
- **Staff(職員)** — 飼育員・獣医。
- **Breeding(繁殖)** — 繁殖ペアと血統管理。
- **Events(イベント)** — `AnimalBorn` / `AnimalDied` ドメインイベントと記録 mixin `Recorder`。

## 集約と不変条件(Aggregates & Invariants)

### Animal(動物個体) — 集約ルート
- 識別子で同一性が決まる。状態は振る舞いを通じてのみ変化する。
- 体力は `Health` 値オブジェクトで 0〜最大の範囲を保証。
- 加齢(`grow_older`)で空腹が進み、飢餓が続けば衰弱し、寿命超過で死亡する。
- 死因(`old_age` / `starvation` / `illness` など)を記録し、死亡時に `AnimalDied` を発行。
- 食性に合わない餌(`eat`)は拒否する。
- 繁殖適性(`fertile?` / `can_breed_with?`)は同種・異性・成熟・健康を要件とする。

### Enclosure(飼育エリア) — 集約
収容(`admit`)時に次の不変条件を守り、違反は型付きのドメイン例外を送出する。
- 定員を超えない(`CapacityExceeded`)
- 収容する種がエリアの気候に適応できる(`ClimateMismatch`)
- 既存の同居個体と相性が両立する(`IncompatibleCohabitation`)
- 死亡個体は収容しない(`DeadAnimal`)

### Zoo(動物園) — 最上位集約ルート
- 全エリア・職員・収益を束ね、横断的な問い合わせ(全頭数・展示種・絶滅危惧種)を提供。
- `open_for_a_day` で全エリアの時間を進め、死亡個体を回収し、イベントを集約する。

## 設計上の判断

- **捕食関係をサイズで表さない**: 「ライオン(190kg) < シマウマ(350kg) でも捕食する」現実と
  矛盾するため、体重比ではなく**捕食性(肉食・魚食)の有無**で安全側に倒し、捕食性の種は
  異種と同居させない方針を採る(`CohabitationPolicy`)。草食動物同士の混合展示は許可する。
- **時間は外部から与える**: `Date.now` 等に依存せず、`grow_older(days)` や `advance(days)` で
  時間経過を明示的に進める。これによりライフサイクルが決定的でテスト可能になる。
- **値オブジェクトは不変**: 体力・空腹などの増減は必ず新しいインスタンスを返す。
