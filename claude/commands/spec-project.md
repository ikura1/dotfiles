仕様書駆動開発（Spec-Driven Development）+ TDD で新規プロジェクトを作成します。

**対象**: $ARGUMENTS

プロジェクトディレクトリは `/home/ikura1/repos/<project-name>/` に作成してください。

---

## ワークフロー

以下のステップを順番に実行してください。

### Step 1: 仕様書作成（spec-writer）

`spec-writer` エージェントを使って、要求から技術非依存の仕様書を作成します。

- 出力: `specs/spec.md`
- ユーザーストーリー（P1/P2/P3）・機能要件・成功基準を定義
- 不明点は `[NEEDS CLARIFICATION: 質問]` でマーキング

**Step 1 完了後**: spec.md に `[NEEDS CLARIFICATION]` 項目があれば、
ユーザーに確認・補足を求めてください。解消してから次へ進む。

---

### Step 2: 技術計画作成（spec-planner）

`spec-planner` エージェントを使って、spec.md から技術計画を作成します。

- 出力: `specs/plan.md`（必須）
- 必要に応じて: `specs/research.md`・`specs/data-model.md`
- 技術スタック選定・ディレクトリ構造・フェーズ別実装計画を含む

---

### Step 3: MAGI 評決（設計フェーズ）

`magi-melchior`・`magi-balthasar`・`magi-casper` の3エージェントを**並列で**起動し、
`specs/spec.md` と `specs/plan.md` の設計を評価させます。

3エージェントの投票結果を集計してください:
- **2/3 APPROVE → 可決**: Step 4 へ進む
- **2/3 REJECT → 否決**: REJECT した理由を `spec-planner` にフィードバックし、
  plan.md を修正させた後、Step 3 を再実行する

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
         MAGI システム 評決集計（設計フェーズ）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  MELCHIOR-1 : [APPROVE ✅ / REJECT ❌]
  BALTHASAR-2: [APPROVE ✅ / REJECT ❌]
  CASPER-3   : [APPROVE ✅ / REJECT ❌]
──────────────────────────────────
  多数決結果 : [可決 ✅ / 否決 ❌]  ([N]/3 APPROVE)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### Step 4: タスクリスト生成（spec-tasker）

`spec-tasker` エージェントを使って、plan.md から実行可能なタスクリストを生成します。

- 出力: `specs/tasks.md`
- ユーザーストーリー別にフェーズを分ける
- テストタスクを実装タスクより先に配置（TDD 順序）

---

### Step 5+: TDD 実装ループ（ユーザーストーリーごと）

tasks.md の各ユーザーストーリーを、以下の TDD サイクルで実装します。
**P1 から順番に、1ストーリーずつ完了させてから次へ進む。**

#### Step 5a: テスト作成 RED（dev-tester）

`dev-tester` エージェントを使って、対象ユーザーストーリーのテストを作成します。

- tasks.md のテストタスク（T0XX）を実行
- テストを実行して **失敗することを確認する**（RED フェーズ）
- 失敗確認なしで次へ進まないこと

#### Step 5b: 実装 GREEN（dev-developer）

`dev-developer` エージェントを使って、テストが通る最小限の実装を行います。

- tasks.md の実装タスクを実行
- テストを実行して **全テストがパスすることを確認する**（GREEN フェーズ）

#### Step 5c: リファクタ REFACTOR（dev-developer）

`dev-developer` エージェントを使ってコードを改善します。

- 可読性・DRY・命名の改善
- テストを再実行して **まだパスすることを確認する**（REFACTOR フェーズ）

**各ユーザーストーリーの Checkpoint**: ストーリーが独立してテスト可能な状態を確認してから次へ。

---

### Step 6: コードレビュー（dev-reviewer）

全ユーザーストーリーの実装完了後、`dev-reviewer` エージェントでコードレビューを実施します。

- CRITICAL/HIGH 問題があれば `dev-developer` で修正
- 修正後にレビューを再確認

---

### Step 7: セキュリティレビュー（security-reviewer、必要に応じて）

以下に該当する場合は `security-reviewer` エージェントを使用します:
- 認証・認可のコードがある
- ユーザー入力を受け付ける
- 外部 API・データベースを使用する

---

### Step 8: MAGI 最終評決（実装フェーズ）

`magi-melchior`・`magi-balthasar`・`magi-casper` を**並列で**起動し、
最終実装を評価させます。

- **2/3 APPROVE → 可決**: 完了
- **2/3 REJECT → 否決**: `dev-developer` に修正指示 → Step 8 を再実行

---

## 完了報告

すべてのステップ完了後、以下を報告してください:

```
## /spec-project 完了

### 生成物
- specs/spec.md      ✅
- specs/plan.md      ✅
- specs/tasks.md     ✅
- src/               ✅
- tests/             ✅
- README.md          ✅

### TDD サイクル
- User Story 1 (P1): RED ✅ → GREEN ✅ → REFACTOR ✅
- User Story 2 (P2): RED ✅ → GREEN ✅ → REFACTOR ✅

### テスト結果
- 成功: N / N
- カバレッジ: XX%（目標 80%）

### MAGI 評決
- 設計フェーズ: 可決 ✅ (N/3 APPROVE)
- 実装フェーズ: 可決 ✅ (N/3 APPROVE)

### プロジェクトパス
/home/ikura1/repos/<project-name>/
```
