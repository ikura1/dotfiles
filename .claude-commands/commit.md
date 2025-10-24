# Claude Command: Commit

This command helps you create well-formatted commits with conventional commit messages in Japanese.

## Usage

To create a commit, just type:
```
/commit
```

Or with options:
```
/commit --no-verify
```

## What This Command Does

1. Unless specified with `--no-verify`, automatically runs pre-commit checks:
   - `pnpm lint` to ensure code quality
   - `pnpm build` to verify the build succeeds
   - `pnpm generate:docs` to update documentation
2. Checks which files are staged with `git status`
3. If 0 files are staged, automatically adds all modified and new files with `git add`
4. Performs a `git diff` to understand what changes are being committed
5. Analyzes the diff to determine if multiple distinct logical changes are present
6. If multiple distinct changes are detected, suggests breaking the commit into multiple smaller commits
7. For each commit (or the single commit if not split), creates a commit message using conventional commit format in Japanese

## Best Practices for Commits

- **Verify before committing**: Ensure code is linted, builds correctly, and documentation is updated
- **Atomic commits**: Each commit should contain related changes that serve a single purpose
- **Split large changes**: If changes touch multiple concerns, split them into separate commits
- **Conventional commit format**: Use the format `<type>: <description>` where type is one of:
  - `feat`: A new feature
  - `fix`: A bug fix
  - `docs`: Documentation changes
  - `style`: Code style changes (formatting, etc)
  - `refactor`: Code changes that neither fix bugs nor add features
  - `perf`: Performance improvements
  - `test`: Adding or fixing tests
  - `chore`: Changes to the build process, tools, etc.
- **Japanese commit messages**: Write commit messages in Japanese using polite language
- **Concise first line**: Keep the first line under 72 characters

## Guidelines for Splitting Commits

When analyzing the diff, consider splitting commits based on these criteria:

1. **Different concerns**: Changes to unrelated parts of the codebase
2. **Different types of changes**: Mixing features, fixes, refactoring, etc.
3. **File patterns**: Changes to different types of files (e.g., source code vs documentation)
4. **Logical grouping**: Changes that would be easier to understand or review separately
5. **Size**: Very large changes that would be clearer if broken down

## Examples

Good commit messages (in Japanese):
- feat: ユーザー認証システムを追加
- fix: レンダリングプロセスのメモリリークを修正
- docs: 新しいエンドポイントのAPIドキュメントを更新
- refactor: パーサーのエラーハンドリングロジックを簡素化
- fix: コンポーネントファイルのリンター警告を解決
- chore: 開発者ツールのセットアッププロセスを改善
- feat: トランザクション検証のビジネスロジックを実装
- fix: ヘッダーの軽微なスタイリング不整合を修正
- fix: 認証フローの重要なセキュリティ脆弱性を修正
- style: より良い可読性のためにコンポーネント構造を再編成
- fix: 非推奨のレガシーコードを削除
- feat: ユーザー登録フォームの入力検証を追加
- fix: 失敗するCIパイプラインテストを解決
- feat: ユーザーエンゲージメントのアナリティクス追跡を実装
- fix: 認証パスワード要件を強化
- feat: スクリーンリーダー用のフォームアクセシビリティを改善

Example of splitting commits (in Japanese):
- First commit: feat: 新しいsolcバージョンの型定義を追加
- Second commit: docs: 新しいsolcバージョンのドキュメントを更新
- Third commit: chore: package.jsonの依存関係を更新
- Fourth commit: feat: 新しいAPIエンドポイントの型定義を追加
- Fifth commit: feat: ワーカースレッドの並行処理を改善
- Sixth commit: fix: 新しいコードのリンティング問題を解決
- Seventh commit: test: 新しいsolcバージョン機能のユニットテストを追加
- Eighth commit: fix: セキュリティ脆弱性のある依存関係を更新

## Command Options

- `--no-verify`: Skip running the pre-commit checks (lint, build, generate:docs)

## Important Notes

- By default, pre-commit checks (`pnpm lint`, `pnpm build`, `pnpm generate:docs`) will run to ensure code quality
- If these checks fail, you'll be asked if you want to proceed with the commit anyway or fix the issues first
- If specific files are already staged, the command will only commit those files
- If no files are staged, it will automatically stage all modified and new files
- The commit message will be constructed based on the changes detected
- Before committing, the command will review the diff to identify if multiple commits would be more appropriate
- If suggesting multiple commits, it will help you stage and commit the changes separately
- Always reviews the commit diff to ensure the message matches the changes
