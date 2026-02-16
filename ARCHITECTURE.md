# アーキテクチャ設計: Claude dotfiles 管理システム

## 概要

`~/.claude/` 配下の `agents/`、`commands/`、`rules/` をシンボリックリンクで
`~/repos/dotfiles/claude/` から管理するシステム。`~/.claude/` 全体はリンクせず、
Claude が自動生成するファイル（statsig, todos, cache 等）は管理対象外とする。

---

## 技術スタック

- 言語: Bash (POSIX 互換は不要、bashism 許容)
- ビルドツール: GNU Make
- 追加依存: なし（coreutils のみ）
- 対象環境: Linux / WSL2

---

## ディレクトリ構造

### リポジトリ構造

```
~/repos/dotfiles/
  .bashrc
  .zshrc
  .emacs.el
  .python-version
  .gitignore
  CLAUDE.md                    # プロジェクト固有の Claude 設定
  CLAUDE-BASE.md               # ~/.claude/CLAUDE.md にコピーされるベース設定
  AGENT_TEAM.md                # エージェントチーム使用ガイド
  ARCHITECTURE.md              # 本ドキュメント
  Makefile                     # claude 関連ターゲットを含む
  install.sh                   # dotfiles 全体のインストール
  claude/                      # Claude 設定の実体（正規ディレクトリ）
    agents/                    #   ~/.claude/agents -> ここへ symlink
      dev-pm.md
      dev-ux-designer.md
      dev-architect.md
      dev-developer.md
      dev-reviewer.md
      dev-tester.md
      security-reviewer.md
      spec-writer.md
      spec-planner.md
      spec-tasker.md
      magi-melchior.md
      magi-balthasar.md
      magi-casper.md
      t-wada.md
    commands/                  #   ~/.claude/commands -> ここへ symlink
      commit.md
      create-worktrees.md
      gemini-search.md
      review-branch.md
      new-project.md
      spec-project.md
      magi-vote.md
      tdd.md
    rules/                     #   ~/.claude/rules -> ここへ symlink
      agents.md
      coding-style.md
      security.md
      testing.md
      git-workflow.md
  scripts/                     # インストールスクリプト群
    lib.sh                     #   共通関数ライブラリ
    install-claude.sh          #   Claude symlink 作成
    uninstall-claude.sh        #   Claude symlink 解除・復元
    status-claude.sh           #   symlink 状態表示
  tests/
    test-claude-install.sh     #   install/uninstall 自動テスト
  .claude/
    settings.local.json        # ローカル権限設定
```

### ホームディレクトリ側の状態（インストール後）

```
~/.claude/
  agents/    -> ~/repos/dotfiles/claude/agents/    (symlink)
  commands/  -> ~/repos/dotfiles/claude/commands/  (symlink)
  rules/     -> ~/repos/dotfiles/claude/rules/     (symlink)
  CLAUDE.md                                        (cp: CLAUDE-BASE.md からコピー)
  backups/                                         (バックアップ格納先)
    agents.bak.20260215_143022/
    commands.bak.20260215_143022/
  statsig/                                         (管理対象外: Claude 自動生成)
  todos/                                           (管理対象外: Claude 自動生成)
  ...
```

---

## リファクタリング: 旧構造から新構造への移行

### 解決すべき問題

#### 問題 1: コマンドファイルの重複

`.claude-commands/`（旧）と `claude/commands/`（新）に同一内容のファイルが4つ存在する。

| ファイル | `.claude-commands/` | `claude/commands/` | 備考 |
|---|---|---|---|
| `commit.md` | 存在 | 存在 | 完全一致を確認済み |
| `create-worktrees.md` | 存在 | 存在 | 差分確認が必要 |
| `gemini-search.md` | 存在 | 存在 | 差分確認が必要 |
| `review-branch.md` | 存在 | 存在 | 差分確認が必要 |
| `new-project.md` | - | 存在 | 新規のみ |
| `spec-project.md` | - | 存在 | 新規のみ |
| `magi-vote.md` | - | 存在 | 新規のみ |
| `tdd.md` | - | 存在 | 新規のみ |

#### 問題 2: CLAUDE.md が旧構造を参照

`CLAUDE.md` の以下の箇所が `.claude-commands/` を参照している:

- 16行目: `このリポジトリには .claude-commands/ に配置された...`
- 88行目: `カスタムClaudeコマンド: .claude-commands/*.md`
- 98行目: `Claudeコマンドは .claude-commands/ に保存され...`

#### 問題 3: ハードコードされたパス `/home/ikura1/`

| ファイル | 該当行 | 用途 |
|---|---|---|
| `claude/commands/new-project.md` | 22, 29, 50行目 | プロジェクト出力先パス |
| `claude/commands/spec-project.md` | 5, 157行目 | プロジェクト出力先パス |
| `claude/agents/dev-architect.md` | 83行目 | プロジェクト出力先パス |
| `tests/test-claude-install.sh` | 5, 139, 140行目 | スクリプトパスとdotfilesパス |
| `AGENT_TEAM.md` | 83, 269行目 | ドキュメント内のパス例 |

**対象外**: `.bashrc`（25, 38, 39行目）と `.zshrc`（271行目）の PNPM_HOME 等はシェル環境固有の設定であり、本リファクタリングの対象外とする。

---

### 変更計画

#### 変更 1: `.claude-commands/` ディレクトリの削除

**方針**: `claude/commands/` に完全な上位互換が存在するため、旧ディレクトリを丸ごと削除する。

**事前確認**:
- 4ファイル全ての差分を確認し、`claude/commands/` 側に差分があればマージ
- `install.sh` が `.claude-commands/` を参照していないことを確認

**操作**:
```bash
git rm -r .claude-commands/
```

#### 変更 2: CLAUDE.md の更新

**方針**: `.claude-commands/` への参照を全て `claude/commands/` に変更し、新構造を正確に反映する。

**変更箇所**:

1. Claudeコマンドセクション（16行目付近）:
   - 変更前: `このリポジトリには .claude-commands/ に配置されたカスタムClaudeコマンドが含まれています`
   - 変更後: `このリポジトリには claude/commands/ に配置されたカスタムClaudeコマンドが含まれています`
   - コマンド一覧を8件全て記載する

2. ファイル構造セクション（88行目付近）:
   - 変更前: `カスタムClaudeコマンド: .claude-commands/*.md`
   - 変更後: `Claude設定: claude/（agents/, commands/, rules/）`

3. カスタムコマンドシステムセクション（97-101行目）:
   - 変更前: `Claudeコマンドは .claude-commands/ に保存され`
   - 変更後: `Claudeコマンドは claude/commands/ に保存され`
   - エージェントとルールの説明も追加

4. 新規追加: `make install-claude` によるインストール方法の説明

#### 変更 3: ハードコードパスの汎用化（Claude設定ファイル）

**方針**: `/home/ikura1/repos/` を `~/repos/` に置換する。Claude Code の実行時にシェル変数 `$HOME` の展開として `~` が解釈されるため、環境依存を排除できる。

**対象ファイルと変更内容**:

`claude/commands/new-project.md`（3箇所）:
```
変更前: /home/ikura1/repos/<project-name>/
変更後: ~/repos/<project-name>/
```

`claude/commands/spec-project.md`（2箇所）:
```
変更前: /home/ikura1/repos/<project-name>/
変更後: ~/repos/<project-name>/
```

`claude/agents/dev-architect.md`（1箇所）:
```
変更前: /home/ikura1/repos/<project-name>/
変更後: ~/repos/<project-name>/
```

`AGENT_TEAM.md`（2箇所）:
```
変更前: /home/ikura1/repos/<project-name>/
変更後: ~/repos/<project-name>/

変更前: /magi-vote /home/ikura1/repos/my-tool/ARCHITECTURE.md
変更後: /magi-vote ~/repos/my-tool/ARCHITECTURE.md
```

#### 変更 4: テストファイルのハードコードパス修正

**方針**: `BASH_SOURCE[0]` からスクリプト自身の位置を基準にパスを自動算出する。

`tests/test-claude-install.sh` の変更:

```bash
# 変更前 (139-140行目):
SCRIPTS_DIR="/home/ikura1/repos/dotfiles/scripts"
REAL_DOTFILES_DIR="/home/ikura1/repos/dotfiles"

# 変更後:
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)"
REAL_DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
```

```bash
# 変更前 (5行目、コメント):
#   bash /home/ikura1/repos/dotfiles/tests/test-claude-install.sh

# 変更後:
#   bash <dotfiles-repo>/tests/test-claude-install.sh
```

---

### 実装順序

変更の依存関係と安全性を考慮した実施順序:

1. **Step 1**: `.claude-commands/` と `claude/commands/` の重複4ファイルの差分確認
2. **Step 2**: 差分がある場合は `claude/commands/` 側にマージ
3. **Step 3**: `tests/test-claude-install.sh` のハードコードパス修正 + テスト実行
4. **Step 4**: Claude設定ファイルのパス汎用化（`new-project.md`, `spec-project.md`, `dev-architect.md`）
5. **Step 5**: `AGENT_TEAM.md` のパス汎用化
6. **Step 6**: `CLAUDE.md` の更新（旧構造参照の修正）
7. **Step 7**: `.claude-commands/` の削除（`git rm -r`）
8. **Step 8**: 最終テスト実行 + `make status` で状態確認

### リスク評価

| リスク | 影響度 | 対策 |
|---|---|---|
| 重複ファイルに差分がある | 中 | Step 1 で差分確認、Step 2 でマージ |
| `install.sh` が `.claude-commands/` を参照 | 低 | 事前確認（現状 `claude/` のみ対象） |
| テストのパス自動解決が環境依存で壊れる | 低 | `${BASH_SOURCE[0]}` は bash の標準機能 |
| `~/repos/` パスが他環境で異なる | 低 | `~` は `$HOME` に展開される |

### コミット計画（推奨: 2コミット構成）

```
refactor: Claude設定のハードコードパスを汎用化

- claude/commands/new-project.md, spec-project.md のパスを ~/repos/ に変更
- claude/agents/dev-architect.md のパスを ~/repos/ に変更
- tests/test-claude-install.sh のパスを BASH_SOURCE ベースの自動解決に変更
- AGENT_TEAM.md のパスを ~/repos/ に変更
```

```
refactor: 旧 .claude-commands/ を削除し CLAUDE.md を新構造に更新

- .claude-commands/ ディレクトリを削除（claude/commands/ に統合済み）
- CLAUDE.md の参照を claude/ 構造に更新
```

---

## シンボリックリンク戦略

### 採用: ディレクトリ単位のシンボリックリンク

`agents/`、`commands/`、`rules/` の各ディレクトリ全体を 1 つの symlink にする。

### 根拠

| 観点 | ディレクトリ単位 | ファイル単位 |
|------|-----------------|-------------|
| 管理対象の追加 | ファイルを置くだけ | install-claude 再実行が必要 |
| symlink 数 | 3 本（固定） | ファイル数に比例 |
| 実装の複雑さ | 単純 | glob 展開・差分管理が必要 |
| ディレクトリ内の一貫性 | 保証される | 一部だけリンク漏れのリスク |
| 制約 | ディレクトリ内の全ファイルが管理対象 | 個別に管理対象外を作れる |

### 管理対象ディレクトリ

```bash
CLAUDE_MANAGED_DIRS=(agents commands rules)
```

---

## 主要コンポーネント

### 1. `scripts/lib.sh` -- 共通関数ライブラリ

全スクリプトから `source` される共通関数群。

**定数**:
```bash
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CLAUDE_HOME="${CLAUDE_HOME:-${HOME}/.claude}"
CLAUDE_SRC_DIR="${DOTFILES_DIR}/claude"
CLAUDE_BACKUP_DIR="${CLAUDE_HOME}/backups"
CLAUDE_MANAGED_DIRS=(agents commands rules)
```

**主要関数**:
- `setup_colors()` -- TTY 判定と NO_COLOR を考慮してカラー変数を設定
- `log_action(action, message)` -- `[action] message` 形式で出力、DRY_RUN 対応
- `log_error(message)` -- stderr に赤太字でエラー出力
- `log_header(message)` -- セクション開始行を出力
- `log_summary(created, skipped, backed_up)` -- サマリー出力
- `ensure_dir(path)` -- mkdir -p を DRY_RUN 考慮で実行
- `backup_dir(dir_name)` -- タイムスタンプ付きバックアップ
- `create_symlink(src, dest)` -- DRY_RUN 考慮の ln -s
- `remove_symlink(path)` -- symlink 確認後に rm
- `get_link_status(dir_name)` -- 状態判定（correct/wrong_target/directory/missing/other）
- `find_latest_backup(dir_name)` -- 最新バックアップパスを返す
- `validate_source_dir(dir_name)` -- ソースディレクトリの存在確認
- `validate_dotfiles_dir()` -- DOTFILES_DIR の存在確認

### 2. `scripts/install-claude.sh` -- Claude 設定インストール

処理フロー:
1. `validate_dotfiles_dir()` でリポジトリの存在確認
2. `CLAUDE_MANAGED_DIRS` をループ:
   - `correct` -> skip
   - `directory` -> `backup_dir()` + `create_symlink()`
   - `wrong_target` -> エラー出力（手動対応を促す）
   - `missing` -> `create_symlink()`
3. `CLAUDE-BASE.md` を `~/.claude/CLAUDE.md` にコピー
4. `log_summary()` でサマリー出力

### 3. `scripts/uninstall-claude.sh` -- Claude 設定アンインストール

処理フロー:
1. `CLAUDE_MANAGED_DIRS` をループ:
   - symlink でなければスキップ
   - `remove_symlink()` で削除
   - バックアップあり -> mv で復元
   - バックアップなし -> mkdir -p で空ディレクトリ作成

### 4. `scripts/status-claude.sh` -- 状態表示

処理フロー:
1. `CLAUDE_MANAGED_DIRS` をループして状態とファイル数を表示
2. backups/ のエントリ数を表示
3. サマリー出力

---

## データフロー

### install-claude 実行時

```
make install-claude
  |
  v
scripts/install-claude.sh
  |
  +-- source scripts/lib.sh
  |
  +-- validate_dotfiles_dir()
  |
  +-- for dir in agents commands rules:
  |     |
  |     +-- validate_source_dir(dir)
  |     +-- get_link_status(dir)
  |     +-- [状態に応じた分岐]
  |           +-- correct:      skip
  |           +-- directory:    backup_dir() -> create_symlink()
  |           +-- wrong_target: log_error(...)
  |           +-- missing:      create_symlink()
  |
  +-- cp CLAUDE-BASE.md -> ~/.claude/CLAUDE.md
  |
  +-- log_summary()
```

---

## エラーハンドリング方針

- `set -euo pipefail` を全スクリプトの先頭に記載
- エラー発生時は `log_error()` で原因と修正方法（`Fix:` 行）を出力
- 1 つのディレクトリでエラーが発生しても、残りのディレクトリの処理は続行
- wrong_target（競合 symlink）は自動上書きせずエラーとして報告
- バックアップのタイムスタンプ衝突時はエラーとして中断（上書き防止）

---

## 設計上の判断記録

### なぜ `~/.claude/` 全体を symlink しないのか

Claude Code は `~/.claude/` 直下に以下のファイルを自動生成・更新する:
- `statsig/`, `todos/`, `cache/` -- 一時データ
- `settings.json` -- ユーザー設定
- `.credentials.json` -- 認証情報

これらを Git 管理下に置くのは不適切であり、サブディレクトリ単位の symlink で管理対象を明確に制御する。

### なぜ `scripts/` を分離するのか

`install.sh` に全ロジックを埋め込むとファイル肥大化・単独実行不可・共通関数の再利用不可になるため、`scripts/lib.sh` に共通ロジックを切り出し、各操作を独立スクリプトにする。

### なぜ CLAUDE-BASE.md は symlink でなく cp なのか

`~/.claude/CLAUDE.md` はプロジェクト横断のベース設定であり、現行の `cp` 方式を維持して明示的な管理とする。将来 symlink に変更する場合は `install-claude.sh` 内の 1 行変更で対応可能。

---

Generated with [Claude Code](https://claude.ai/code)
