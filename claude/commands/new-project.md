新規プロジェクトを開発エージェントチームで作成します。

**プロジェクト情報**: $ARGUMENTS

以下のワークフローで開発を進めてください。必ず各ステップで指定のエージェントを使用してください。

---

## ワークフロー

### ステップ 1: 要件分析（dev-pm）
`dev-pm` エージェントを使って要件を分析し、タスクリストを作成してください。
- プロジェクト名と目的を明確にする
- 機能要件・非機能要件を整理する
- 各エージェントへの具体的な指示を作成する

### ステップ 2: UX設計（dev-ux-designer）
`dev-ux-designer` エージェントを使ってユーザー体験を設計してください。
- dev-pm の要件を引き継ぐ
- コマンド構造・オプション・引数を設計する
- エラーメッセージ・ヘルプテキストを設計する
- `/home/ikura1/repos/<project-name>/UX_DESIGN.md` を作成する

### ステップ 3: アーキテクチャ設計（dev-architect）
`dev-architect` エージェントを使って技術設計を行ってください。
- dev-pm の成果物と dev-ux-designer の UX設計を引き継ぐ
- 技術スタックを選定する
- ディレクトリ構造を設計する
- `/home/ikura1/repos/<project-name>/ARCHITECTURE.md` を作成する

### ステップ 4: MAGI 第1評決 — アーキテクチャ承認

`magi-melchior`、`magi-balthasar`、`magi-casper` の3エージェントを順番に起動し、
`ARCHITECTURE.md` と `UX_DESIGN.md` を評価させてください。

評決を集計し、以下の集計表を出力してください：
```
MELCHIOR-1 : [APPROVE / REJECT]
BALTHASAR-2: [APPROVE / REJECT]
CASPER-3   : [APPROVE / REJECT]
→ 多数決: [可決 / 否決]
```

- **可決（2/3 APPROVE）** → ステップ5へ進む
- **否決（2/3 REJECT）** → `dev-architect` に REJECT 理由を伝えて修正させ、再評決を実施する

### ステップ 5: 実装（dev-developer）
`dev-developer` エージェントを使ってコードを実装してください。
- `UX_DESIGN.md` と `ARCHITECTURE.md` の設計に従って実装する
- `/home/ikura1/repos/<project-name>/` にすべてのファイルを作成する
- `README.md` も作成する

### ステップ 6: コードレビュー（dev-reviewer）
`dev-reviewer` エージェントを使って実装コードをレビューしてください。
- バグ・セキュリティ問題・コード品質を確認する

### ステップ 6b: 修正（必要な場合）
重大な問題があった場合、`dev-developer` エージェントを使ってレビュー指摘を修正してください。

### ステップ 7: MAGI 第2評決 — 実装承認

`magi-melchior`、`magi-balthasar`、`magi-casper` の3エージェントを順番に起動し、
実装コードとコードレビュー結果を評価させてください。

評決を集計し、以下の集計表を出力してください：
```
MELCHIOR-1 : [APPROVE / REJECT]
BALTHASAR-2: [APPROVE / REJECT]
CASPER-3   : [APPROVE / REJECT]
→ 多数決: [可決 / 否決]
```

- **可決（2/3 APPROVE）** → ステップ8へ進む
- **否決（2/3 REJECT）** → `dev-developer` に REJECT 理由を伝えて修正させ、再評決を実施する

### ステップ 8: テスト（dev-tester）
`dev-tester` エージェントを使ってテストを作成・実行してください。
- ユニットテストを作成する
- テストを実行して結果を報告する

---

## 完了報告

全ステップ完了後、以下をまとめて報告してください：
- 作成したプロジェクトのパス
- 主要ファイル一覧
- 実行方法
- テスト結果のサマリー
