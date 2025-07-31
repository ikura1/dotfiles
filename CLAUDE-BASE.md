# CLAUDE-BASE.md

このファイルは、Claude Code (claude.ai/code) がすべてのプロジェクトで共通して従うべき基本ルールを定義します。

## 基本原則

### 開発方針
- 日本語でのコミットメッセージと説明を優先する
- **すべての応答は日本語で行う**
- セキュリティを最優先に考慮する
- 最小限の変更で最大の効果を目指す
- 既存のコードスタイルとパターンに従う

### コミット規則
- **Conventional Commits仕様に厳密に従う**
- 形式: `<type>[optional scope]: <description>`
- 破壊的変更がある場合は`!`を付ける: `<type>!: <description>`
- 本文と脚注は必要に応じて追加
- 英語でのコミットメッセージを推奨（日本語も可）

#### 必須コミットタイプ（Conventional Commits準拠）
- `feat`: 新機能の追加
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの動作に影響しない変更（空白、フォーマット、セミコロン等）
- `refactor`: バグ修正でも機能追加でもないコード変更
- `perf`: パフォーマンスを向上させるコード変更
- `test`: テストの追加や既存テストの修正
- `build`: ビルドシステムや外部依存関係に影響する変更
- `ci`: CI設定ファイルやスクリプトの変更
- `chore`: その他の変更（src/testファイルを変更しない）
- `revert`: 以前のコミットを取り消す

#### コミットメッセージの例
```
feat: add email notifications
fix: resolve memory leak in image processing
docs: update API documentation
feat!: change authentication method (BREAKING CHANGE)
fix(parser): handle edge case in JSON parsing
```

### セキュリティ
- APIキーやトークンなどの機密情報をコードに含めない
- セキュリティ関連の変更は慎重に行う
- パスワードや認証情報をコミットしない

### コード品質
- リント・フォーマットツールがある場合は必ず実行する
- テストがある場合は実行して通過を確認する
- 破壊的変更は避ける

### ドキュメント作成規則
- 新規にmarkdownなどのドキュメントを作成する場合は、Claude Codeを使用して作成したことを明記する
- ドキュメント末尾に以下の署名を追加：
  ```
  🤖 Generated with [Claude Code](https://claude.ai/code)
  ```

## 禁止事項
- 機密情報の露出
- 既存機能の意図的な破壊
- 不必要な大規模リファクタリング
- セキュリティリスクを増加させる変更
- Conventional Commitsに準拠しないコミットメッセージ

🤖 Generated with [Claude Code](https://claude.ai/code)