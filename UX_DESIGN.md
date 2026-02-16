# UX設計書: Claude dotfiles 管理システム

## 概要

`~/.claude/` 配下の `agents/`, `commands/`, `rules/` をシンボリックリンクで
`~/repos/dotfiles/` から管理するためのコマンドインタラクション設計書。

対象ユーザー: Linux/WSL2 環境に慣れたエンジニア。dotfiles の概念を理解しているが、
スクリプトの詳細を逐一読まない。エラー発生時に原因と対処法をすぐ知りたい。

---

## コマンドリファレンス

```
make [TARGET] [OPTIONS]
```

### ターゲット一覧

```
  install            dotfiles 全体をインストール（シェル設定 + Claude 設定）
  install-claude     Claude 設定のみをインストール（symlink 作成）
  uninstall-claude   Claude 設定の symlink を解除し、バックアップを復元
  status             現在の symlink 状態を確認
  help               このヘルプを表示
```

### オプション

```
  DRY_RUN=1   実際の変更を行わず、実行予定の操作を表示する
  VERBOSE=1   詳細な操作ログを表示する
```

### 各ターゲット詳細

#### `make install`

dotfiles 全体をインストールする。シェル設定（.bashrc, .zshrc, .emacs.el）と
Claude 設定の両方を処理する。`make install-claude` を内包する。

```
make install
make install DRY_RUN=1    # 変更内容を事前確認
```

#### `make install-claude`

`~/.claude/` 配下の `agents/`, `commands/`, `rules/` ディレクトリを
`~/repos/dotfiles/claude/` 以下へのシンボリックリンクに置き換える。

既存のディレクトリが存在する場合はタイムスタンプ付きバックアップを作成してから
symlink を設置する。冪等性あり（既に symlink が正しく設定済みの場合はスキップ）。

```
make install-claude
make install-claude DRY_RUN=1    # 変更内容を事前確認
```

#### `make uninstall-claude`

`~/.claude/` 配下の symlink を解除する。バックアップが存在する場合は
最新のバックアップを復元する。バックアップがない場合は空ディレクトリを残す。

```
make uninstall-claude
make uninstall-claude DRY_RUN=1
```

#### `make status`

現在の symlink 状態と、dotfiles リポジトリ側のファイル数を表示する。
変更を加えない読み取り専用操作。

```
make status
```

---

## リポジトリのディレクトリ構造

```
~/repos/dotfiles/
  claude/
    agents/       # ~/.claude/agents/ の実体
    commands/     # ~/.claude/commands/ の実体
    rules/        # ~/.claude/rules/   の実体
  .bashrc
  .zshrc
  .emacs.el
  Makefile
  install.sh
```

```
~/.claude/
  agents   -> ~/repos/dotfiles/claude/agents/   (symlink)
  commands -> ~/repos/dotfiles/claude/commands/ (symlink)
  rules    -> ~/repos/dotfiles/claude/rules/    (symlink)
  backups/
    agents.bak.20260215_143022/   # 退避された旧ディレクトリ
```

---

## ユーザーフロー

### ハッピーパス 1: 初回インストール（Claude 設定がまだない）

```
$ make install-claude
```

```
[claude] Installing Claude dotfiles...

  [create] ~/.claude/agents   -> ~/repos/dotfiles/claude/agents
  [create] ~/.claude/commands -> ~/repos/dotfiles/claude/commands
  [create] ~/.claude/rules    -> ~/repos/dotfiles/claude/rules

[claude] Done. 3 symlinks created.
```

所要時間: 即時。バックアップなし（既存ファイルがないため）。

### ハッピーパス 2: 既存ディレクトリがある場合のインストール

```
$ make install-claude
```

```
[claude] Installing Claude dotfiles...

  [backup] ~/.claude/agents   -> ~/.claude/backups/agents.bak.20260215_143022
  [create] ~/.claude/agents   -> ~/repos/dotfiles/claude/agents
  [backup] ~/.claude/commands -> ~/.claude/backups/commands.bak.20260215_143022
  [create] ~/.claude/commands -> ~/repos/dotfiles/claude/commands
  [skip]   ~/.claude/rules    (already symlinked correctly)

[claude] Done. 2 symlinks created, 1 skipped, 2 backups saved.
         Backups: ~/.claude/backups/
```

### ハッピーパス 3: 冪等実行（すべて設定済み）

```
$ make install-claude
```

```
[claude] Installing Claude dotfiles...

  [skip] ~/.claude/agents   (already symlinked correctly)
  [skip] ~/.claude/commands (already symlinked correctly)
  [skip] ~/.claude/rules    (already symlinked correctly)

[claude] Done. Nothing to do. All symlinks are up to date.
```

### ハッピーパス 4: dry-run による事前確認

```
$ make install-claude DRY_RUN=1
```

```
[claude] DRY RUN - no changes will be made

  [would backup] ~/.claude/agents   -> ~/.claude/backups/agents.bak.20260215_143022
  [would create] ~/.claude/agents   -> ~/repos/dotfiles/claude/agents
  [would skip]   ~/.claude/commands (already symlinked correctly)
  [would create] ~/.claude/rules    -> ~/repos/dotfiles/claude/rules

[claude] DRY RUN complete. Run without DRY_RUN=1 to apply.
```

### ハッピーパス 5: アンインストール（バックアップあり）

```
$ make uninstall-claude
```

```
[claude] Uninstalling Claude dotfiles...

  [remove]  ~/.claude/agents   (symlink removed)
  [restore] ~/.claude/agents   <- ~/.claude/backups/agents.bak.20260215_143022
  [remove]  ~/.claude/commands (symlink removed)
  [restore] ~/.claude/commands <- ~/.claude/backups/commands.bak.20260215_143022
  [remove]  ~/.claude/rules    (symlink removed)
  [empty]   ~/.claude/rules    (no backup found, created empty directory)

[claude] Done. 2 directories restored, 1 created empty.
```

### ハッピーパス 6: status 確認

```
$ make status
```

```
[claude] Symlink status

  ~/.claude/agents   -> ~/repos/dotfiles/claude/agents   [OK]  2 files
  ~/.claude/commands -> ~/repos/dotfiles/claude/commands [OK]  4 files
  ~/.claude/rules    (not a symlink - plain directory)   [--]  1 file

  Backups: ~/.claude/backups/ (2 entries)

[claude] 2/3 managed by dotfiles.
```

---

## エラーパス

### E1: dotfiles 側のディレクトリが存在しない

発生条件: `~/repos/dotfiles/claude/commands/` が作成されていない。

```
[claude] ERROR: Source directory not found.

  Expected: ~/repos/dotfiles/claude/commands/
  Found:    (does not exist)

  Fix: Create the directory and add files to it.
       mkdir -p ~/repos/dotfiles/claude/commands
```

### E2: symlink のリンク先が別のパスを指している（競合）

発生条件: `~/.claude/commands` が既に別の場所へのシンボリックリンクになっている。

```
[claude] ERROR: Symlink conflict detected.

  Path:     ~/.claude/commands
  Current:  -> /some/other/path/commands  (unexpected target)
  Expected: -> ~/repos/dotfiles/claude/commands

  Fix: Remove the existing symlink manually and re-run.
       rm ~/.claude/commands
       make install-claude
```

### E3: バックアップ先に同名ディレクトリが既に存在する

発生条件: 同一タイムスタンプでバックアップが衝突（通常は起こり得ないが安全策）。

```
[claude] ERROR: Backup destination already exists.

  Path: ~/.claude/backups/agents.bak.20260215_143022

  Fix: Remove or rename the conflicting backup directory.
       rm -rf ~/.claude/backups/agents.bak.20260215_143022
```

### E4: 書き込み権限がない

```
[claude] ERROR: Permission denied.

  Cannot write to: ~/.claude/
  Current user:    ikura1

  Fix: Check directory ownership and permissions.
       ls -la ~/.claude/
```

### E5: make コマンドを dotfiles リポジトリ以外から実行した

発生条件: `cd` せずに `make -C` などで呼び出した場合など、
`DOTFILES_DIR` の検出に失敗したとき。

```
[claude] ERROR: Dotfiles directory not found.

  Expected: ~/repos/dotfiles/
  Found:    (does not exist)

  Fix: Run make from within the dotfiles repository.
       cd ~/repos/dotfiles && make install-claude
```

---

## 出力フォーマット設計

### プレフィックス記号の意味

```
[create]        新規 symlink を作成した
[skip]          既に正しく設定済みのためスキップした
[backup]        既存ディレクトリをバックアップに退避した
[restore]       バックアップからディレクトリを復元した
[remove]        symlink を削除した
[empty]         空ディレクトリを作成した（バックアップなし）
[OK]            状態確認：正常
[--]            状態確認：dotfiles 管理外
[would ...]     DRY_RUN=1 時の仮想的な操作表示
[claude]        セクションヘッダー（開始・完了・エラー）
ERROR:          エラーメッセージ
```

### カラーリング仕様（ANSI エスケープコード）

```
[create]    緑      \e[32m    正常な変更操作
[skip]      シアン  \e[36m    情報（変更なし）
[backup]    黄      \e[33m    注意を要する操作（既存を退避）
[restore]   青      \e[34m    復元操作
[remove]    黄      \e[33m    削除操作
[empty]     シアン  \e[36m    情報（変更なし）
[would ..]  暗灰    \e[2m     DRY_RUN のシミュレーション
ERROR:      赤太字  \e[1;31m  エラー
[OK]        緑      \e[32m    正常状態
[--]        灰      \e[2m     管理外状態
```

ターミナルが色をサポートしない場合（`NO_COLOR` 環境変数または非 TTY）は
カラーコードを出力しない。

### 出力の密度

- 通常モード: 各ディレクトリ 1 行 + 最後のサマリー行
- `VERBOSE=1` 時: バックアップの絶対パス、symlink の `readlink` 結果も表示
- サマリー行は常に表示する（`QUIET=1` でも）

### サマリー行の形式

```
[claude] Done. {N} symlinks created, {N} skipped, {N} backups saved.
[claude] Done. Nothing to do. All symlinks are up to date.
[claude] Done. {N} directories restored, {N} created empty.
```

---

## DRY_RUN フラグの設計

### 採用理由

dotfiles のインストールはホームディレクトリを直接変更する破壊的な操作であり、
特に既存ファイルのバックアップが絡む場面では、事前に何が起きるかを確認できることが
ユーザーの安心感につながる。

`--dry-run` ではなく `DRY_RUN=1` を採用する理由:
- `make` は引数ではなく変数渡しが慣用的（`make install DRY_RUN=1`）
- `--dry-run` は `make` 自体のオプションと紛らわしい（`make --dry-run` は make の dry-run）

### DRY_RUN=1 の動作原則

- ファイルシステムへの書き込み・削除・移動を一切行わない
- 読み取り（存在確認・symlink 先の確認）は行う
- 実際の実行と同じ判定ロジックで「行うはずだった操作」を表示する
- 出力の先頭に `DRY RUN - no changes will be made` と明記する

---

## UX 上の配慮事項

### 1. 冪等性の明示的フィードバック

再実行時に `[skip]` を表示することで、「何も起きなかった（壊れた？）」という
不安をなくす。「正しく設定済みのためスキップした」という意図が伝わる出力にする。

### 2. バックアップの透明性

バックアップがどこに作られたかを必ず出力する。ユーザーが「自分のファイルが
消えた」と思わないようにするための安心設計。タイムスタンプ付きにすることで
複数回の実行でバックアップが上書きされないことも保証する。

### 3. エラーメッセージの Fix 行

すべてのエラーメッセージに `Fix:` セクションを設け、次に何をすべきかを
具体的なコマンドで示す。「何が悪いか」だけでなく「どう直すか」まで伝える。

### 4. DRY_RUN のデフォルト非採用

デフォルトで dry-run にすると「なぜ何も変わらないんだ」という混乱を招く。
初回ユーザーへの配慮として `install-claude` のヘルプに `DRY_RUN=1` の
使い方を記載し、オプトインで使えるようにする。

### 5. `make` の慣習への準拠

`make help` で全ターゲットと変数を一覧表示する。`make` の `--dry-run` と
区別するため変数渡し（`DRY_RUN=1`）を採用する。ターゲット名は動詞-名詞の
命名（`install-claude`, `uninstall-claude`）で git の慣習（`git remote add/remove`）
に揃える。

### 6. `make install` との統合

既存の `make install` フローを壊さない。`make install` が `make install-claude` を
内包することで、新しいマシンへのセットアップが 1 コマンドで完結する。
`make install-claude` 単体でも動作するため、Claude 設定だけ更新したい
ユースケースにも対応する。

### 7. status コマンドの提供

「今どういう状態か」を確認する読み取り専用コマンドを用意することで、
ユーザーがシステムの現在状態を把握できる手段を常に確保する。
インストール後のセルフチェックや、環境移行後の確認に使える。

### 8. 非 TTY 環境への配慮

CI やスクリプトから呼び出された場合（`stdout` が非 TTY）はカラーコードを
出力しない。`NO_COLOR` 環境変数も尊重する（https://no-color.org/）。
これにより、ログファイルや pipe 経由の出力が読みやすい状態を保つ。
