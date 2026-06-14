# OOP-Zoo フロントエンド

動物園 JSON API を消費する SPA（Vue 3 + TypeScript + Vite + Pinia）。

## アーキテクチャ（バックの層構造をミラーした薄いクライアント）

```
components/        … presentational（props を受けて描くだけ・状態を持たない）
components/forms/  … 操作フォーム（ストアのアクションを呼ぶ container 的コンポーネント）
stores/zoo.ts      … ViewModel（表示状態・取得・操作後の再取得・通知/エラーの一元管理）
api/client.ts      … Gateway（通信の唯一の口・エラー契約の解釈）
api/schema.ts      … Model（../openapi.yaml から openapi-typescript で生成。手で編集しない）
```

ビジネスルールはサーバが唯一の正であり、フロントには複製しない。種・餌・綱などの
選択肢も参照データ API（`/species` `/foods` `/taxon-classes`）から取得する。

## セットアップ

```sh
npm install
npm run gen:types   # ../openapi.yaml → src/api/schema.ts を生成
```

`openapi.yaml`（API の契約）を変更したら `npm run gen:types` を再実行する。

## 開発（フロントとAPIを別オリジンで動かす）

```sh
# 1) API サーバ（リポジトリルートで）
bundle exec ruby bin/zoo-web        # http://localhost:4567 （SQLite 永続化）

# 2) フロント dev server（この frontend/ で）
npm run dev                          # http://localhost:5173
```

dev server は CORS 経由で API を叩く。API のベースURLは `VITE_API_BASE`
（既定 `http://localhost:4567`）で差し替え可能。

## 本番（同一オリジンで配信）

```sh
npm run build                        # dist/ を生成
bundle exec ruby bin/zoo-web         # dist があれば http://localhost:4567 で SPA を配信
```

## 検証

```sh
npm run typecheck   # vue-tsc
npm test            # vitest（api client・store のロジック）
```
