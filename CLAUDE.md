# CLAUDE.md

このファイルは、Claude Code (claude.ai/code) がこのリポジトリのコードを操作する際のガイダンスを提供します。

## リポジトリ概要

これは、シェルとエディタの設定ファイルを含む個人的なdotfilesリポジトリです。このリポジトリは、複数のシェル（bash、zsh）とEmacsエディタの設定を管理します。

## 共通コマンド

### セットアップとインストール
- `./install.sh` - ホームディレクトリからリポジトリファイルへのシンボリックリンクを作成してdotfilesをインストール
- パッケージインストール（apt update、pip install）にはsudoアクセスが必要

### Claudeコマンド
このリポジトリには `claude/commands/` に配置されたカスタムClaudeコマンドが含まれています：
- `/commit` - 従来型コミットメッセージと絵文字を使用した整形済みコミットの作成
- `/review-branch` - 複数の視点（PM、開発者、QA、セキュリティ、DevOps、UI/UX）からの包括的ブランチレビュー
- `/create-worktrees` - Git worktree の作成・管理
- `/gemini-search` - Gemini を使ったウェブ検索
- `/new-project` - 開発エージェントチームで新規プロジェクトを作成
- `/spec-project` - 仕様書駆動開発（Spec-Driven Development）+ TDD で新規プロジェクトを作成
- `/magi-vote` - MAGI システムによる多数決評価
- `/tdd` - TDD（テスト駆動開発）ワークフロー
- カスタムコマンドは `scripts/install-claude.sh` でシンボリックリンクを作成します

## インストールとセットアップ

### dotfilesのインストール
- `./install.sh` を使用してdotfilesをインストールします
- インストールスクリプトはホームディレクトリからこのリポジトリのdotfilesへのシンボリックリンクを作成します
- パッケージインストール（apt update、pip install）にはsudoアクセスが必要です

### Claude設定のインストール
- `make install-claude` または `bash scripts/install-claude.sh` を実行します
- `~/.claude/agents/`、`~/.claude/commands/`、`~/.claude/rules/` が `claude/` 配下へのシンボリックリンクとして作成されます（ファイル追加は即時反映）
- `CLAUDE-BASE.md` が `~/.claude/CLAUDE.md` に初回のみコピーされます（既に存在する場合はスキップ。更新するには手動で再コピーしてください）
- `make status-claude` で現在のシンボリックリンク状態を確認できます
- `make uninstall-claude` でシンボリックリンクを解除してバックアップから復元できます

### 依存関係
- Python 3 with pip
- uv - モダンなPythonパッケージおよびプロジェクトマネージャー
- pyenv - Pythonバージョン管理用
- Volta - Node.js管理用
- pnpm - パッケージ管理用
- Rust/Cargo環境

## 設定ファイル構造

### シェル設定
- `.bashrc` - PATHセットアップとツール初期化を含むBash設定
- `.zshrc` - 包括的なエイリアス、関数、プロンプトカスタマイゼーションを含む拡張Zsh設定

### エディタ設定
- `.emacs.el` - カスタムキーバインディング、視覚的設定、空白ハイライトを含むEmacs設定

### 環境セットアップ
- `.python-version` - システムPythonの使用を示す「system」を含む
- `.gitignore` - VS Code設定とEmacs一時ファイルを無視

## 主な機能

### シェル環境
- すべてのシェルがPythonバージョン管理用のpyenv統合で設定されています
- Node.js/npm管理用のVolta統合
- Rust/Cargo環境の読み込み
- 各シェル用のカスタムエイリアスとプロンプト
- ディレクトリ自動補完とナビゲーションショートカット

### 開発ツール統合
- エイリアスとヘルパー関数を含む、モダンなPythonパッケージとプロジェクト管理用のuv
- すべてのシェルにおけるPythonバージョン管理用のpyenv
- パッケージ管理用に設定されたpnpm
- Cargo/Rust環境統合
- ユーザーインストールツール用のローカルbinディレクトリのPATH

### エディタセットアップ
- ターミナル使用用に設定されたEmacs（`emacs -nw`エイリアス）
- カスタムキーバインディング（バックスペース用C-h、アンドゥ用C-/）
- 視覚的拡張（行ハイライト、括弧マッチング、カスタムカラー）
- より良いコード整形のための空白と全角スペースハイライト

## シェル固有の注意事項

### Zsh設定のハイライト
- 拡張履歴管理（10,000エントリ、重複排除）
- Git、開発、システム操作用の包括的なエイリアスコレクション
- エイリアス付きUV Pythonパッケージマネージャー統合（uvi、uvr、uva、uvsなど）
- GitステータスとPython環境表示を含む高度なプロンプト
- 便利な関数（mkcd、extract、ファイル検索用ff、uvnew、uvenv、uvdev）
- 改良されたキーバインディングと自動補完
- シンタックスハイライトと自動提案用のプラグインサポート
- 遅延読み込みによるパフォーマンス最適化

## 主要アーキテクチャ情報

### ファイル構造
- 主要なdotfiles: `.bashrc`, `.zshrc`, `.emacs.el`
- 環境設定: `.python-version`, `.gitignore`
- Claude設定: `claude/`（`agents/`, `commands/`, `rules/`）
  - `claude/agents/` - AI エージェント定義（dev-pm, dev-architect, magi-* など）
  - `claude/commands/` - カスタムClaudeコマンド（commit, review-branch など）
  - `claude/rules/` - コーディングルール・ガイドライン
- インストールスクリプト: `install.sh`（dotfiles全体）、`scripts/install-claude.sh`（Claude設定）

### シェル設定アーキテクチャ
- bashとzshの両方の設定に包括的なツール統合が含まれています
- zsh設定にはgitステータスとPython環境表示を含む高度なプロンプトカスタマイゼーションが含まれています
- カスタムエイリアスと関数を含むUV Pythonパッケージマネージャー統合
- 開発ワークフロー最適化のための包括的なエイリアスコレクション

### Claude設定システム
- Claudeコマンドは `claude/commands/` に保存され、`scripts/install-claude.sh` でシンボリックリンクを作成します
- AIエージェントは `claude/agents/` に保存されます（`~/.claude/agents/` へシンボリックリンク）
- コーディングルールは `claude/rules/` に保存されます（`~/.claude/rules/` へシンボリックリンク）
- コマンドは使用方法とベストプラクティスを含む構造化フォーマットに従います
- `/commit` コマンドには絵文字ベースの従来型コミットガイドラインが含まれています
- `/review-branch` コマンドは多角的なコードレビューテンプレートを提供します