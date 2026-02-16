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

### 変更後のリポジトリ構造

```
~/repos/dotfiles/
  .bashrc
  .zshrc
  .emacs.el
  .python-version
  .gitignore
  CLAUDE.md
  CLAUDE-BASE.md
  UX_DESIGN.md
  ARCHITECTURE.md          # 本ドキュメント
  Makefile                 # 変更: claude 関連ターゲット追加
  install.sh               # 変更: claude セットアップを呼び出す
  claude/                  # 新規: Claude 設定の実体
    agents/                #   ~/.claude/agents -> ここへ symlink
      *.md
    commands/              #   ~/.claude/commands -> ここへ symlink
      commit.md
      create-worktrees.md
      gemini-search.md
      review-branch.md
    rules/                 #   ~/.claude/rules -> ここへ symlink
      *.md
  scripts/                 # 新規: インストールスクリプト群
    lib.sh                 #   共通関数ライブラリ
    install-claude.sh      #   Claude symlink 作成
    uninstall-claude.sh    #   Claude symlink 解除・復元
    status-claude.sh       #   symlink 状態表示
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

ディレクトリ内のファイルを個別に管理対象外にする必要性は現時点でないため、
シンプルなディレクトリ単位を採用する。将来ファイル単位が必要になった場合は
`scripts/install-claude.sh` のリンク作成ロジックのみ変更すればよい。

### 管理対象ディレクトリ

以下の 3 ディレクトリのみを管理対象とする。この一覧は `scripts/lib.sh` 内で
配列として定義し、追加・削除が容易な設計にする。

```bash
CLAUDE_MANAGED_DIRS=(agents commands rules)
```

---

## 主要コンポーネント

### 1. `scripts/lib.sh` -- 共通関数ライブラリ

全スクリプトから `source` される共通関数群。

```bash
#!/bin/bash
# scripts/lib.sh -- Claude dotfiles 共通ライブラリ

# --- 定数 ---
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/repos/dotfiles}"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
CLAUDE_SRC_DIR="${DOTFILES_DIR}/claude"
CLAUDE_BACKUP_DIR="${CLAUDE_HOME}/backups"
CLAUDE_MANAGED_DIRS=(agents commands rules)

# --- 環境変数（オプション） ---
# DRY_RUN=1  : 変更を行わない
# VERBOSE=1  : 詳細ログ
# NO_COLOR=1 : カラー無効化

# --- カラー出力 ---
setup_colors()
#   TTY 判定と NO_COLOR を考慮してカラー変数を設定する
#   呼び出し: 各スクリプトの先頭で 1 回

log_action(action, message)
#   "[action] message" 形式で出力する
#   action に応じたカラーを自動適用
#   DRY_RUN=1 時は action を "would ${action}" に変換
#   例: log_action "create" "~/.claude/agents -> ~/repos/dotfiles/claude/agents"

log_error(message)
#   "[claude] ERROR: message" を stderr に赤太字で出力

log_header(message)
#   "[claude] message" をセクション開始行として出力

log_summary(created, skipped, backed_up)
#   "[claude] Done. ..." サマリー行を出力

# --- ファイルシステム操作 ---
ensure_dir(path)
#   mkdir -p を DRY_RUN 考慮で実行

backup_dir(src_path)
#   src_path を CLAUDE_BACKUP_DIR にタイムスタンプ付きで移動
#   戻り値: バックアップ先のパス
#   DRY_RUN=1 時はログのみ

create_symlink(src, dest)
#   ln -s を DRY_RUN 考慮で実行

remove_symlink(path)
#   symlink であることを確認してから rm
#   通常ディレクトリの場合はエラー

# --- 状態判定 ---
is_correct_symlink(link_path, expected_target)
#   link_path が expected_target を指す symlink か判定
#   戻り値: 0 (正しい) / 1 (不一致または非 symlink)

get_link_status(dir_name)
#   指定ディレクトリの状態を判定する
#   戻り値(stdout): "correct" | "wrong_target" | "directory" | "missing" | "other"

find_latest_backup(dir_name)
#   dir_name の最新バックアップパスを返す
#   バックアップがない場合は空文字列

count_files(dir_path)
#   ディレクトリ内のファイル数を返す（再帰なし）

# --- バリデーション ---
validate_source_dir(dir_name)
#   CLAUDE_SRC_DIR/dir_name が存在するか確認
#   存在しない場合はエラーメッセージを出力して return 1

validate_dotfiles_dir()
#   DOTFILES_DIR が存在するか確認
```

### 2. `scripts/install-claude.sh` -- Claude 設定インストール

```bash
#!/bin/bash
# scripts/install-claude.sh -- Claude dotfiles のシンボリックリンクを作成する
#
# Usage: ./scripts/install-claude.sh [DRY_RUN=1] [VERBOSE=1]
#
# 処理フロー:
#   1. validate_dotfiles_dir() でリポジトリの存在確認
#   2. CLAUDE_MANAGED_DIRS をループ:
#      a. validate_source_dir() でソースの存在確認
#      b. get_link_status() で現在の状態を判定
#      c. "correct"   -> skip
#      d. "directory"  -> backup_dir() してから create_symlink()
#      e. "wrong_target" -> エラー出力（手動対応を促す）
#      f. "missing"   -> create_symlink()
#   3. CLAUDE-BASE.md を ~/.claude/CLAUDE.md にコピー
#   4. log_summary() でサマリー出力

source "$(dirname "$0")/lib.sh"
```

### 3. `scripts/uninstall-claude.sh` -- Claude 設定アンインストール

```bash
#!/bin/bash
# scripts/uninstall-claude.sh -- symlink を解除し、バックアップを復元する
#
# 処理フロー:
#   1. CLAUDE_MANAGED_DIRS をループ:
#      a. symlink でなければスキップ
#      b. remove_symlink() で symlink 削除
#      c. find_latest_backup() でバックアップを検索
#      d. バックアップあり -> mv で復元
#      e. バックアップなし -> mkdir -p で空ディレクトリ作成
#   2. サマリー出力

source "$(dirname "$0")/lib.sh"
```

### 4. `scripts/status-claude.sh` -- 状態表示

```bash
#!/bin/bash
# scripts/status-claude.sh -- 現在の symlink 状態を表示する
#
# 処理フロー:
#   1. CLAUDE_MANAGED_DIRS をループ:
#      a. get_link_status() で状態取得
#      b. count_files() でファイル数取得
#      c. 1 行で状態を表示
#   2. backups/ のエントリ数を表示
#   3. サマリー("N/3 managed by dotfiles")

source "$(dirname "$0")/lib.sh"
```

---

## 既存ファイルへの変更方針

### `install.sh` の変更

既存の `install.sh` は最小限の変更に留める。Claude 設定の処理を
`scripts/install-claude.sh` に委譲する形にする。

```bash
# 変更前（削除対象の行）:
mkdir -p ~/.claude/commands
cp ~/repos/dotfiles/.claude-commands/*.md ~/.claude/commands/
cp ~/repos/dotfiles/CLAUDE-BASE.md ~/.claude/CLAUDE.md

# 変更後（追加する行）:
bash "$(dirname "$0")/scripts/install-claude.sh"
```

既存のシェル設定リンク（.bashrc, .zshrc, .emacs.el）には一切触れない。

### `Makefile` の変更

既存の `install` ターゲットはそのまま維持し、新規ターゲットを追加する。

```makefile
# 既存（変更なし）
install:
	./install.sh

# 新規追加
install-claude:
	@bash scripts/install-claude.sh

uninstall-claude:
	@bash scripts/uninstall-claude.sh

status:
	@bash scripts/status-claude.sh

help:
	@echo "Targets:"
	@echo "  install            dotfiles 全体をインストール"
	@echo "  install-claude     Claude 設定のみ（symlink 作成）"
	@echo "  uninstall-claude   Claude symlink を解除・復元"
	@echo "  status             symlink 状態を確認"
	@echo "  help               このヘルプ"
	@echo ""
	@echo "Options:"
	@echo "  DRY_RUN=1          変更を行わず予定操作を表示"
	@echo "  VERBOSE=1          詳細ログを表示"

.PHONY: install install-claude uninstall-claude status help
```

`DRY_RUN` と `VERBOSE` は Make 変数として渡され、スクリプト内で環境変数として参照される。
`make install-claude DRY_RUN=1` と実行すると、Make が `DRY_RUN=1` を環境に
エクスポートするため、スクリプト側で特別な受け渡し処理は不要。

### `.claude-commands/` からの移行

既存の `.claude-commands/*.md` の内容を `claude/commands/` に移動する。
`.claude-commands/` ディレクトリは互換性のため一定期間残してもよいが、
`install.sh` からの `cp` 処理は削除する。

移行手順:
1. `mkdir -p claude/commands`
2. `mv .claude-commands/*.md claude/commands/`
3. `install.sh` の `cp` 行を削除、`scripts/install-claude.sh` 呼び出しに置換
4. `.claude-commands/` を削除（または `.gitkeep` で残す）

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
  |     ~/repos/dotfiles/ が存在するか確認
  |
  +-- for dir in agents commands rules:
  |     |
  |     +-- validate_source_dir(dir)
  |     |     ~/repos/dotfiles/claude/{dir}/ が存在するか確認
  |     |
  |     +-- get_link_status(dir)
  |     |     ~/.claude/{dir} の現在の状態を判定
  |     |
  |     +-- [状態に応じた分岐]
  |           |
  |           +-- correct:      log_action("skip", ...)
  |           +-- directory:    backup_dir() -> create_symlink()
  |           +-- wrong_target: log_error(...) -> continue
  |           +-- missing:      create_symlink()
  |
  +-- cp CLAUDE-BASE.md -> ~/.claude/CLAUDE.md
  |
  +-- log_summary()
```

### symlink の作成・削除の流れ

```
[作成]
  ~/repos/dotfiles/claude/commands/  (実体)
       ^
       |  ln -s
       |
  ~/.claude/commands  (symlink)


[バックアップ]
  ~/.claude/commands/  (既存の通常ディレクトリ)
       |
       |  mv
       v
  ~/.claude/backups/commands.bak.20260215_143022/  (退避)


[復元]
  ~/.claude/commands  (symlink)
       |
       |  rm (symlink のみ削除)
       v
  ~/.claude/backups/commands.bak.20260215_143022/
       |
       |  mv
       v
  ~/.claude/commands/  (通常ディレクトリとして復元)
```

---

## エラーハンドリング方針

### スクリプト全体

- `set -euo pipefail` を全スクリプトの先頭に記載
- エラー発生時は `log_error()` で原因と修正方法（`Fix:` 行）を出力
- 1 つのディレクトリでエラーが発生しても、残りのディレクトリの処理は続行する
  （`set -e` の影響を受けないよう、エラーは関数内で処理して戻り値で判定）

### wrong_target（競合 symlink）の扱い

既に別のパスへの symlink が存在する場合は、自動で上書きせずエラーとして報告する。
理由: ユーザーが意図的に別の場所を指している可能性があり、無断で変更すると
データロスにつながる。

### バックアップのタイムスタンプ衝突

`date +%Y%m%d_%H%M%S` で秒単位の一意性を確保する。万が一衝突した場合は
エラーとして報告し、処理を中断する（上書き防止）。

---

## テスト方針

bash スクリプトのテストは以下の方法で行う。

### 手動テスト手順

1. `DRY_RUN=1` で全操作の事前確認
2. 初回インストール（クリーン環境）
3. 冪等性確認（2 回目の実行）
4. 既存ディレクトリがある状態でのインストール（バックアップ動作）
5. アンインストールとバックアップ復元
6. status 表示の正確性

### テスト用スクリプト（将来的に追加可能）

```
tests/
  test-claude-install.sh    # 一時ディレクトリで install/uninstall を自動テスト
```

テスト用スクリプトでは `CLAUDE_HOME` と `DOTFILES_DIR` を一時ディレクトリに
上書きすることで、実環境を汚さずにテストできる設計になっている。

---

## 作成・変更するファイル一覧

| ファイル | 操作 | 説明 |
|----------|------|------|
| `claude/agents/` | 新規作成 | agents 実体ディレクトリ（初期は空、`.gitkeep` を配置） |
| `claude/commands/*.md` | 移動 | `.claude-commands/` から移動 |
| `claude/rules/` | 新規作成 | rules 実体ディレクトリ（初期は空、`.gitkeep` を配置） |
| `scripts/lib.sh` | 新規作成 | 共通関数ライブラリ |
| `scripts/install-claude.sh` | 新規作成 | インストールスクリプト |
| `scripts/uninstall-claude.sh` | 新規作成 | アンインストールスクリプト |
| `scripts/status-claude.sh` | 新規作成 | 状態表示スクリプト |
| `install.sh` | 変更 | cp 行を削除、scripts/install-claude.sh 呼び出しに置換 |
| `Makefile` | 変更 | install-claude, uninstall-claude, status, help ターゲット追加 |
| `.claude-commands/` | 削除 | claude/commands/ へ移行後に削除 |

---

## 設計上の判断記録

### なぜ `~/.claude/` 全体を symlink しないのか

Claude Code は `~/.claude/` 直下に以下のファイルを自動生成・更新する:
- `statsig/` -- 機能フラグのキャッシュ
- `todos/` -- タスク管理データ
- `cache/` -- 各種キャッシュ
- `settings.json` -- ユーザー設定
- `.credentials.json` -- 認証情報

これらを Git 管理下に置くのは不適切（機密情報・一時データ）であり、
`~/.claude/` 全体を symlink するとこれらも dotfiles リポジトリに含まれてしまう。
サブディレクトリ単位の symlink により、管理対象を明確に制御する。

### なぜ `scripts/` を分離するのか

`install.sh` に全ロジックを埋め込むと以下の問題が生じる:
- ファイルが肥大化し保守性が低下する
- `uninstall-claude` や `status` を独立して実行できない
- 共通関数の再利用ができない

`scripts/lib.sh` に共通ロジックを切り出し、各操作を独立スクリプトにすることで、
単一責任の原則を守り、テスタビリティも確保する。

### なぜ CLAUDE-BASE.md は symlink でなく cp なのか

`~/.claude/CLAUDE.md` はプロジェクト横断のベース設定ファイルであり、
Claude Code が読み取る。symlink にしても動作上は問題ないが、
各プロジェクトの `CLAUDE.md` と異なる層のファイルであるため、
現行の `cp` 方式を維持して明示的な管理とする。
将来的に symlink に変更する場合は `install-claude.sh` 内の 1 行を
変更するだけでよい。
