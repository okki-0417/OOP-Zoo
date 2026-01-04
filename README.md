# OOP-Zoo - 動物園シミュレーション

オブジェクト指向プログラミングの概念を学ぶために作成した、C#による動物園シミュレーションアプリケーションです。

## 概要

動物園のオーナーとなり、動物の購入・管理を行うコンソールアプリケーションです。
オブジェクト指向の基本的な概念（カプセル化、単一責任の原則、値オブジェクトなど）を実践的に学ぶことを目的としています。

## 必要環境

- .NET 9.0 SDK

## 実行方法

```bash
cd ZooSim
dotnet run
```

## テスト実行

```bash
dotnet test
```

## プロジェクト構成

```
ZooApp/
├── ZooSim/                    # メインアプリケーション
│   ├── Program.cs             # エントリーポイント
│   ├── Applications/
│   │   └── ZooSimulation.cs   # シミュレーションのメインロジック
│   ├── Models/
│   │   ├── Animal/
│   │   │   ├── Animal.cs      # 動物クラス
│   │   │   └── AnimalName.cs  # 動物名（値オブジェクト）
│   │   ├── Zoo/
│   │   │   ├── Zoo.cs         # 動物園クラス
│   │   │   └── ZooName.cs     # 動物園名（値オブジェクト）
│   │   ├── ZooOwner/
│   │   │   ├── ZooOwner.cs    # 動物園オーナークラス
│   │   │   └── ZooOwnerName.cs# オーナー名（値オブジェクト）
│   │   ├── AnimalTrader.cs    # 動物商人クラス
│   │   ├── BuyableAnimal.cs   # 購入可能な動物
│   │   └── ZooFinance.cs      # 動物園の資金管理
│   └── umls/                  # UML図（PlantUML）
├── ZooSim.Tests/              # ユニットテスト
└── ZooApp.sln                 # ソリューションファイル
```

## 学べるオブジェクト指向の概念

### 1. カプセル化
- `ZooFinance`クラスでは`IsPayable`メソッドをprivateにし、外部から直接資金の支払い可否を判定させず、`PayIfPayable`を通じてのみ操作を許可

### 2. 値オブジェクト
- `AnimalName`、`ZooName`、`ZooOwnerName`など、プリミティブ型をラップした値オブジェクトを使用
- ドメインの概念を型で表現することで、コードの意図が明確に

### 3. 単一責任の原則
- `Zoo`は動物の管理に専念
- `ZooFinance`は資金管理に専念
- `AnimalTrader`は動物の売買に専念

### 4. ドメイン駆動設計（DDD）の入門
- ドメインモデルをModelsディレクトリに集約
- ビジネスロジックをモデル内に閉じ込める設計

## 機能（実装済み / 予定）

- [x] オーナー登録
- [x] 動物園の作成
- [ ] 動物の購入
- [ ] 動物の一覧表示
- [ ] 動物商人との契約
- [ ] 動物の繁殖
- [ ] 他園との動物交換
- [ ] 動物の保護

## ライセンス

MIT License
