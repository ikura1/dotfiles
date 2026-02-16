# 自律型開発エージェントチーム 使用ガイド

Claude Code のネイティブエージェント機能を使って構築した、自律型ソフトウェア開発チームの使用方法です。

---

## 概要

14のエージェント・4つのカスタムコマンド・5つのルールで構成されます。
外部SDKやスクリプトは不要で、Claude Code のデフォルト機能だけで動作します。

```
~/.claude/
├── agents/
│   ├── dev-pm.md             # プロジェクトマネージャー
│   ├── dev-ux-designer.md    # UXデザイナー
│   ├── dev-architect.md      # ソフトウェアアーキテクト
│   ├── dev-developer.md      # 開発者
│   ├── dev-reviewer.md       # コードレビュアー
│   ├── dev-tester.md         # テストエンジニア（TDD）
│   ├── security-reviewer.md  # セキュリティレビュアー
│   ├── spec-writer.md        # 仕様書作成者（SDD）
│   ├── spec-planner.md       # 技術計画立案者（SDD）
│   ├── spec-tasker.md        # タスクリスト生成者（SDD）
│   ├── magi-melchior.md      # MAGI MELCHIOR-1
│   ├── magi-balthasar.md     # MAGI BALTHASAR-2
│   ├── magi-casper.md        # MAGI CASPER-3
│   └── t-wada.md             # 外部顧問（TDD・テスト品質）
├── commands/
│   ├── new-project.md        # /new-project コマンド
│   ├── spec-project.md       # /spec-project コマンド（仕様書駆動+TDD）
│   ├── magi-vote.md          # /magi-vote コマンド
│   └── tdd.md                # /tdd コマンド
└── rules/
    ├── agents.md             # エージェント利用ガイドライン
    ├── coding-style.md       # コーディング規約
    ├── security.md           # セキュリティガイドライン
    ├── testing.md            # テスト要件
    └── git-workflow.md       # Gitワークフロー
```

---

## クイックスタート

### 仕様書駆動 + TDD でプロジェクトを作成する（推奨）

```
/spec-project <プロジェクト名と要件の説明>
```

**例:**
```
/spec-project ディレクトリを再帰的に検索してファイル一覧を表示するCLIツール「flist」
```

実行すると、以下の流れで開発が進みます：

```
仕様書作成 → 技術計画 → MAGI評決
→ タスクリスト生成 → TDD実装ループ（ユーザーストーリーごと）
→ コードレビュー → MAGI最終評決
```

### シンプルなプロジェクトを高速作成する

```
/new-project <プロジェクト名と要件の説明>
```

**例:**
```
/new-project ディレクトリを再帰的に検索してファイル一覧を表示するCLIツール「flist」
```

実行すると、以下の流れで自動的に開発が進みます：

```
要件分析 → UX設計 → アーキテクチャ設計 → MAGI評決
→ 実装 → コードレビュー → MAGI評決 → テスト
```

完了後、`/home/ikura1/repos/<project-name>/` に完成したプロジェクトが生成されます。

---

## ワークフロー詳細

### `/spec-project` の実行ステップ（仕様書駆動 + TDD）

| ステップ | エージェント | 成果物 |
|---|---|---|
| 1. 仕様書作成 | `spec-writer` | `specs/spec.md`（ユーザーストーリー・受け入れ基準） |
| 2. 技術計画作成 | `spec-planner` | `specs/plan.md`（+ `research.md`・`data-model.md`） |
| 3. **MAGI 第1評決** | `magi-*` × 3 | 設計の承認 / 否決 |
| 4. タスクリスト生成 | `spec-tasker` | `specs/tasks.md`（TDD順・US別） |
| 5a. テスト作成（RED） | `dev-tester` | テストコード（失敗を確認） |
| 5b. 実装（GREEN） | `dev-developer` | ソースコード（テスト通過を確認） |
| 5c. リファクタ（REFACTOR） | `dev-developer` | 改善済みコード |
| 6. コードレビュー | `dev-reviewer` | CRITICAL/HIGH/MEDIUM/LOW 別レビュー |
| 7. セキュリティレビュー | `security-reviewer` | セキュリティレポート（必要時） |
| 8. **MAGI 第2評決** | `magi-*` × 3 | 実装の承認 / 否決 |

ステップ 5a〜5c はユーザーストーリーごとに繰り返します（P1 → P2 → P3 の順）。

### `/new-project` の実行ステップ

| ステップ | エージェント | 成果物 |
|---|---|---|
| 1. 要件分析 | `dev-pm` | フェーズ別実装計画・成功基準 |
| 2. UX設計 | `dev-ux-designer` | `UX_DESIGN.md` |
| 3. アーキテクチャ設計 | `dev-architect` | `ARCHITECTURE.md` |
| 4. **MAGI 第1評決** | `magi-*` × 3 | 設計の承認 / 否決 |
| 5. 実装 | `dev-developer` | ソースコード・`README.md` |
| 6. コードレビュー | `dev-reviewer` | CRITICAL/HIGH/MEDIUM/LOW 別レビュー |
| 6b. 修正（必要時） | `dev-developer` | 修正済みコード |
| 7. **MAGI 第2評決** | `magi-*` × 3 | 実装の承認 / 否決 |
| 8. テスト | `dev-tester` | テストコード（TDD）・実行結果 |

### MAGI 評決の仕組み

3つのコンピュータが異なる視点で評価し、**2/3以上の賛成で可決**されます。

```
MELCHIOR-1 : APPROVE ✅   ← 技術的に正しい
BALTHASAR-2: APPROVE ✅   ← リスクは許容範囲
CASPER-3   : REJECT  ❌   ← ユーザー体験に問題あり
→ 多数決: 可決 ✅ (2/3 APPROVE)
```

**否決（2/3 REJECT）の場合:** REJECT したコンピュータの指摘が前のエージェントに
フィードバックされ、修正後に再評決が行われます。

---

## エージェント一覧

### 開発チーム

#### `dev-pm` — プロジェクトマネージャー
- **モデル**: Sonnet / **ツール**: Read, Write, Glob, Grep, TodoWrite
- **役割**: 要件分析・フェーズ別タスク分解・成功基準の定義
- **出力**: フェーズベースの実装計画（MVP スコープ・リスク・テスト戦略含む）

#### `dev-ux-designer` — UXデザイナー
- **モデル**: Sonnet / **ツール**: Read, Write, Glob, Grep
- **役割**: CLIコマンド構造・ユーザーフロー・エラーメッセージ・ヘルプテキスト設計
- **出力**: `UX_DESIGN.md`

#### `dev-architect` — ソフトウェアアーキテクト
- **モデル**: Opus（複雑な設計判断のため最上位モデル）/ **ツール**: Read, Write, Glob, Grep, WebSearch, WebFetch
- **役割**: 技術スタック選定・ディレクトリ構造設計・インターフェース定義
- **出力**: `ARCHITECTURE.md`

#### `dev-developer` — 開発者
- **モデル**: Sonnet / **ツール**: Read, Write, Edit, Bash, Glob, Grep
- **役割**: 設計書に基づくコード実装・依存パッケージインストール・修正対応
- **出力**: ソースコード一式・`README.md`

#### `dev-reviewer` — コードレビュアー
- **モデル**: Sonnet / **ツール**: Read, Glob, Grep（**読み取り専用**）
- **役割**: CRITICAL/HIGH/MEDIUM/LOW の深刻度別レビュー・確信度80%以上の問題のみ報告
- **出力**: 深刻度別レビューコメント + レビューサマリー表

#### `dev-tester` — テストエンジニア
- **モデル**: Sonnet / **ツール**: Read, Write, Edit, Bash, Glob, Grep
- **役割**: TDD（RED→GREEN→REFACTOR）でのテスト作成・実行・カバレッジ測定（目標80%）
- **出力**: テストファイル（`tests/`配下）・TDDサイクル完了報告

#### `security-reviewer` — セキュリティレビュアー
- **モデル**: Sonnet / **ツール**: Read, Glob, Grep（**読み取り専用**）
- **役割**: OWASP Top 10・シークレット検出・インジェクション・認証バイパスの検出
- **出力**: 深刻度別セキュリティレポート（CRITICAL/HIGH/MEDIUM/LOW）
- **使うタイミング**: 新しいAPIエンドポイント・認証コード・ユーザー入力処理・DB操作後

---

### 仕様書駆動チーム（SDD）

#### `spec-writer` — 仕様書作成者
- **モデル**: Sonnet / **ツール**: Read, Write, Glob, Grep
- **役割**: ユーザー要求から技術非依存の仕様書を作成（WHAT と WHY に集中）
- **出力**: `specs/spec.md`（ユーザーストーリー P1/P2/P3・Given/When/Then・機能要件・成功基準）

#### `spec-planner` — 技術計画立案者
- **モデル**: Opus（複雑な技術判断のため最上位モデル）/ **ツール**: Read, Write, Glob, Grep, WebSearch, WebFetch
- **役割**: spec.md を読んで技術スタック選定・アーキテクチャ・実装フェーズを計画
- **出力**: `specs/plan.md`（+ 必要に応じて `specs/research.md`・`specs/data-model.md`）

#### `spec-tasker` — タスクリスト生成者
- **モデル**: Sonnet / **ツール**: Read, Write, Glob, Grep
- **役割**: plan.md から実行可能なタスクリストを生成（TDD順・ユーザーストーリー別）
- **出力**: `specs/tasks.md`（`[P]`並列マーカー付き・正確なファイルパス付き）

---

### 外部顧問

#### `t-wada` — TDD・テスト品質顧問
- **モデル**: Opus（深い洞察のため最上位モデル）/ **ツール**: Read, Glob, Grep（**読み取り専用**）
- **役割**: TDD・テスト戦略・ソフトウェア品質に関するソクラテス式問いかけと洞察の提供
- **出力**: 問い・洞察・提言（コードは書かない）
- **使うタイミング**: TDD サイクルの迷い・テスト設計の議論・「なぜテストを書くのか」の問い直し・dev-tester 成果物の哲学的レビュー

---

### MAGI システム

EVAの「MAGI」に倣い、3つの視点から重要な判断を多数決で評価します。
3エージェントはすべて **読み取り専用**（Read, Glob, Grep のみ）です。

#### `magi-melchior` — MELCHIOR-1（科学者の視点）
- **評価軸**: 技術的正確性・実装効率・アーキテクチャの健全性・コード品質
- **問い**: 「これは技術的に正しく、効率的か？」

#### `magi-balthasar` — BALTHASAR-2（母の視点）
- **評価軸**: セキュリティリスク・保守性・エラーハンドリング・長期的な技術的負債
- **問い**: 「これは安全で、将来も維持できるか？」

#### `magi-casper` — CASPER-3（女性の視点）
- **評価軸**: UX整合性・実用性・要件適合度・ユーザー価値
- **問い**: 「これはユーザーの役に立ち、使いやすいか？」

---

## カスタムコマンド

### `/spec-project`（推奨）

仕様書駆動開発（SDD）+ TDD で新規プロジェクトを作成します。
要件が複雑・中大規模のプロジェクトに適しています。

```
/spec-project <プロジェクトの説明>
```

### `/new-project`

新規プロジェクトをフルワークフローで高速自動開発します。
要件が明確・小規模のプロジェクトに適しています。

```
/new-project <プロジェクトの説明>
```

### `/tdd`

TDD（テスト駆動開発）ワークフローを実行します。`dev-tester` が RED→GREEN→REFACTOR サイクルを厳密に実施します。

```
/tdd <テスト対象の機能や関数の説明>
```

**例:**
```
/tdd src/parser.py の parse_args 関数
```

### `/magi-vote`

単独でMAGIによる多数決評価を実施します。任意の成果物や設計案を評価したい場合に使います。

```
/magi-vote <評価対象の説明またはファイルパス>
```

**例:**
```
/magi-vote /home/ikura1/repos/my-tool/ARCHITECTURE.md を評価してください
```

**出力例:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         MAGI システム 評決集計
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MELCHIOR-1 : APPROVE ✅
  BALTHASAR-2: REJECT  ❌
  CASPER-3   : APPROVE ✅
──────────────────────────────────
  多数決結果 : 可決 ✅  (2/3 APPROVE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## ルール（`~/.claude/rules/`）

Claude Code が全会話で自動的に参照するガイドラインです。

| ファイル | 内容 |
|---|---|
| `agents.md` | エージェントの使い分けガイド・並列実行の指針 |
| `coding-style.md` | 不変性・ファイルサイズ・エラーハンドリング・入力検証 |
| `security.md` | コミット前セキュリティチェックリスト・シークレット管理 |
| `testing.md` | TDD必須・カバレッジ80%以上・テスト種別要件 |
| `git-workflow.md` | Conventional Commits・PRワークフロー・機能実装フロー |

---

## 個別エージェントを直接呼び出す

コマンドを使わず、特定のエージェントだけを呼び出すことも可能です。

**例:**
```
dev-reviewer エージェントを使って src/ 配下のコードをレビューしてください
```

```
security-reviewer エージェントを使って認証周りのコードをセキュリティチェックしてください
```

```
/tdd src/cli.py の引数パーサー
```

---

## 生成されるファイル構成

### `/spec-project` 実行後

```
repos/<project-name>/
├── specs/
│   ├── spec.md          # 仕様書（spec-writer）
│   ├── plan.md          # 技術計画（spec-planner）
│   ├── research.md      # 技術リサーチ（spec-planner、必要時）
│   ├── data-model.md    # データモデル（spec-planner、必要時）
│   └── tasks.md         # タスクリスト（spec-tasker）
├── src/                 # ソースコード（dev-developer）
│   └── ...
├── tests/               # テストコード・TDDで作成（dev-tester）
│   ├── unit/
│   └── integration/
└── README.md            # ユーザー向けドキュメント（dev-developer）
```

### `/new-project` 実行後

```
repos/<project-name>/
├── ARCHITECTURE.md     # アーキテクチャ設計書（dev-architect）
├── UX_DESIGN.md        # UX設計書（dev-ux-designer）
├── README.md           # ユーザー向けドキュメント（dev-developer）
├── src/                # ソースコード（dev-developer）
│   └── ...
└── tests/              # テストコード・TDDで作成（dev-tester）
    ├── unit/
    └── integration/
```

---

## コーディング規約（rules/ より）

| 規約 | 内容 |
|---|---|
| 不変性 | オブジェクトを直接変更しない。スプレッド・map・filter で新オブジェクトを生成 |
| ファイルサイズ | 通常200〜400行・最大800行。超えたらモジュール分割 |
| 関数サイズ | 50行以内。超えたら責務を分割 |
| ネスト | 最大4レベル。早期リターンやヘルパー関数で対応 |
| シークレット | ソースコードにAPIキー・パスワードをハードコードしない |
| テスト | TDD必須。カバレッジ80%以上（認証・決済は100%） |
| コミット | `feat:` `fix:` `refactor:` `docs:` `test:` の Conventional Commits |

---

## コマンドの使い分け

| コマンド | 向いているケース |
|---|---|
| `/spec-project` | 要件が複雑・中大規模・仕様を丁寧に固めたい |
| `/new-project` | 要件が明確・小規模・高速に開発したい |
| `/tdd` | 既存コードに対してテストを追加したい |
| `/magi-vote` | 任意の成果物を MAGI で評価したい |

---

## 注意事項

- `dev-reviewer`・`security-reviewer`・`magi-*`・`t-wada`・`spec-writer`（設計フェーズ）はコードを変更しません
- MAGI が否決した場合は修正ループに入ります。繰り返し否決される場合は要件や設計を見直してください
- `dev-architect`・`spec-planner` は Opus モデルを使用するため、他のエージェントより少し時間がかかります
- セキュリティ問題（CRITICAL）が見つかった場合は、他の作業を止めて必ず修正してください
- `/spec-project` の spec.md に `[NEEDS CLARIFICATION]` が残っている場合、Step 2 に進む前にユーザーへの確認が必要です
