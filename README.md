# dotfiles

個人的な dotfiles リポジトリ。シェル設定と Claude Code 設定を管理します。

## セットアップ

```bash
git clone https://github.com/ikura1/dotfiles ~/repos/dotfiles
cd ~/repos/dotfiles
make install
```

`make install` は以下を行います。

- `.bashrc`, `.zshrc`, `.emacs.el` のシンボリックリンクをホームディレクトリに作成
- Claude 設定（`agents/`, `commands/`, `rules/`）のシンボリックリンクを `~/.claude/` に作成
- システムパッケージのアップデート、uv のインストール

## Claude 設定の管理

`~/.claude/agents/`, `~/.claude/commands/`, `~/.claude/rules/` を
`~/repos/dotfiles/claude/` 以下へのシンボリックリンクで管理します。

```
make install-claude     # Claude 設定のみインストール（symlink 作成）
make uninstall-claude   # Claude symlink を解除し、バックアップを復元
make status             # symlink の現在の状態を確認
make help               # コマンド一覧を表示
```

### オプション

```
make install-claude DRY_RUN=1   # 変更内容を事前確認（実際には変更しない）
make install-claude VERBOSE=1   # 詳細ログを表示
```

### ディレクトリ構造

```
~/repos/dotfiles/
  claude/
    agents/       # ~/.claude/agents/ の実体
    commands/     # ~/.claude/commands/ の実体
    rules/        # ~/.claude/rules/ の実体
  scripts/
    lib.sh              # 共通関数ライブラリ
    install-claude.sh   # symlink 作成スクリプト
    uninstall-claude.sh # symlink 解除・復元スクリプト
    status-claude.sh    # 状態表示スクリプト
  .bashrc
  .zshrc
  .emacs.el
  install.sh
  Makefile
```

インストール後の `~/.claude/` の状態:

```
~/.claude/
  agents/    -> ~/repos/dotfiles/claude/agents/    (symlink)
  commands/  -> ~/repos/dotfiles/claude/commands/  (symlink)
  rules/     -> ~/repos/dotfiles/claude/rules/     (symlink)
  CLAUDE.md                                        (CLAUDE-BASE.md からコピー)
  backups/                                         (バックアップ格納先)
  statsig/                                         (Claude 自動生成 - 管理対象外)
  todos/                                           (Claude 自動生成 - 管理対象外)
```

## 依存関係

- Python 3 with pip
- [uv](https://github.com/astral-sh/uv) - Python パッケージマネージャー
- [pyenv](https://github.com/pyenv/pyenv) - Python バージョン管理
- [Volta](https://volta.sh/) - Node.js 管理
- [pnpm](https://pnpm.io/) - パッケージ管理
- Rust/Cargo 環境
