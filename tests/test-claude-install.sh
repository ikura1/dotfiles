#!/usr/bin/env bash
# tests/test-claude-install.sh -- Claude dotfiles install/uninstall 自動テスト
#
# Usage:
#   bash <dotfiles-repo>/tests/test-claude-install.sh
#
# テスト方針:
#   - 本番環境 (~/.claude/, 実際の dotfiles) には一切触れない
#   - DOTFILES_DIR と CLAUDE_HOME を一時ディレクトリに向けて実行する
#   - テスト後に必ず一時ディレクトリを cleanup する

set -uo pipefail

# ---------------------------------------------------------------------------
# テストフレームワーク（自前 assert 関数）
# ---------------------------------------------------------------------------

PASS=0
FAIL=0
CURRENT_TEST=""

# テストスイート名を設定して出力
describe() {
  local name="${1}"
  printf "\n### %s\n" "${name}"
}

# 個別テスト開始
it() {
  CURRENT_TEST="${1}"
}

# assert_eq: 値が等しいことを確認
assert_eq() {
  local expected="${1}"
  local actual="${2}"
  local label="${3:-assert_eq}"

  if [[ "${expected}" == "${actual}" ]]; then
    printf "  [PASS] %s: %s\n" "${CURRENT_TEST}" "${label}"
    ((PASS++)) || true
  else
    printf "  [FAIL] %s: %s\n" "${CURRENT_TEST}" "${label}"
    printf "         expected: %q\n" "${expected}"
    printf "         actual:   %q\n" "${actual}"
    ((FAIL++)) || true
  fi
}

# assert_symlink: $1 が $2 を指すシンボリックリンクであることを確認
assert_symlink() {
  local link_path="${1}"
  local expected_target="${2}"
  local label="${3:-assert_symlink}"

  if [[ ! -L "${link_path}" ]]; then
    printf "  [FAIL] %s: %s\n" "${CURRENT_TEST}" "${label}"
    printf "         %s is not a symlink\n" "${link_path}"
    ((FAIL++)) || true
    return
  fi

  local actual_target
  actual_target="$(readlink "${link_path}")"

  if [[ "${actual_target}" == "${expected_target}" ]]; then
    printf "  [PASS] %s: %s\n" "${CURRENT_TEST}" "${label}"
    ((PASS++)) || true
  else
    printf "  [FAIL] %s: %s\n" "${CURRENT_TEST}" "${label}"
    printf "         expected target: %q\n" "${expected_target}"
    printf "         actual target:   %q\n" "${actual_target}"
    ((FAIL++)) || true
  fi
}

# assert_exists: パスが存在することを確認
assert_exists() {
  local path="${1}"
  local label="${2:-assert_exists}"

  if [[ -e "${path}" ]] || [[ -L "${path}" ]]; then
    printf "  [PASS] %s: %s\n" "${CURRENT_TEST}" "${label}"
    ((PASS++)) || true
  else
    printf "  [FAIL] %s: %s\n" "${CURRENT_TEST}" "${label}"
    printf "         %s does not exist\n" "${path}"
    ((FAIL++)) || true
  fi
}

# assert_not_exists: パスが存在しないことを確認
assert_not_exists() {
  local path="${1}"
  local label="${2:-assert_not_exists}"

  if [[ ! -e "${path}" ]] && [[ ! -L "${path}" ]]; then
    printf "  [PASS] %s: %s\n" "${CURRENT_TEST}" "${label}"
    ((PASS++)) || true
  else
    printf "  [FAIL] %s: %s\n" "${CURRENT_TEST}" "${label}"
    printf "         %s unexpectedly exists\n" "${path}"
    ((FAIL++)) || true
  fi
}

# assert_contains: ファイルに文字列が含まれることを確認
assert_contains() {
  local file_path="${1}"
  local needle="${2}"
  local label="${3:-assert_contains}"

  if [[ ! -e "${file_path}" ]]; then
    printf "  [FAIL] %s: %s\n" "${CURRENT_TEST}" "${label}"
    printf "         file does not exist: %s\n" "${file_path}"
    ((FAIL++)) || true
    return
  fi

  if grep -qF "${needle}" "${file_path}"; then
    printf "  [PASS] %s: %s\n" "${CURRENT_TEST}" "${label}"
    ((PASS++)) || true
  else
    printf "  [FAIL] %s: %s\n" "${CURRENT_TEST}" "${label}"
    printf "         '%s' not found in %s\n" "${needle}" "${file_path}"
    ((FAIL++)) || true
  fi
}

# ---------------------------------------------------------------------------
# テスト環境セットアップ・クリーンアップ
# ---------------------------------------------------------------------------

# 一時ディレクトリのパス（PID でユニークにする）
TEST_DOTFILES="/tmp/test_dotfiles_$$"
TEST_HOME="/tmp/test_home_$$"

# スクリプトの実際のパス（このテストファイルから見た相対位置）
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)"
REAL_DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# テスト用のフィクスチャを作成する
setup_test_env() {
  # 一時 dotfiles ディレクトリ（claude/ サブディレクトリ付き）を作成
  mkdir -p "${TEST_DOTFILES}/claude/agents"
  mkdir -p "${TEST_DOTFILES}/claude/commands"
  mkdir -p "${TEST_DOTFILES}/claude/rules"
  mkdir -p "${TEST_DOTFILES}/scripts"

  # テスト用のダミーファイルを配置
  echo "# test agent" > "${TEST_DOTFILES}/claude/agents/test-agent.md"
  echo "# test command" > "${TEST_DOTFILES}/claude/commands/test-command.md"
  echo "# test rule" > "${TEST_DOTFILES}/claude/rules/test-rule.md"
  echo "# test CLAUDE-BASE.md" > "${TEST_DOTFILES}/CLAUDE-BASE.md"

  # scripts/ は実際のスクリプトをシンボリックリンクで参照
  # （テスト dotfiles に lib.sh などを別途作らなくて済むよう、scripts は実体へのリンクを張る）
  ln -s "${SCRIPTS_DIR}/lib.sh"             "${TEST_DOTFILES}/scripts/lib.sh"
  ln -s "${SCRIPTS_DIR}/install-claude.sh"  "${TEST_DOTFILES}/scripts/install-claude.sh"
  ln -s "${SCRIPTS_DIR}/uninstall-claude.sh" "${TEST_DOTFILES}/scripts/uninstall-claude.sh"
  ln -s "${SCRIPTS_DIR}/status-claude.sh"   "${TEST_DOTFILES}/scripts/status-claude.sh"

  # テスト用の HOME（~/.claude 相当）を作成
  mkdir -p "${TEST_HOME}/.claude"
}

# テスト環境を破棄する
teardown_test_env() {
  rm -rf "${TEST_DOTFILES}"
  rm -rf "${TEST_HOME}"
}

# 各テスト前にクリーンな状態に戻すためのリセット
reset_claude_home() {
  rm -rf "${TEST_HOME}/.claude"
  mkdir -p "${TEST_HOME}/.claude"
}

# install-claude.sh を安全なテスト環境変数付きで実行する
run_install() {
  DOTFILES_DIR="${TEST_DOTFILES}" \
  CLAUDE_HOME="${TEST_HOME}/.claude" \
  HOME="${TEST_HOME}" \
  NO_COLOR=1 \
  bash "${SCRIPTS_DIR}/install-claude.sh" "$@"
}

# uninstall-claude.sh を安全なテスト環境変数付きで実行する
run_uninstall() {
  DOTFILES_DIR="${TEST_DOTFILES}" \
  CLAUDE_HOME="${TEST_HOME}/.claude" \
  HOME="${TEST_HOME}" \
  NO_COLOR=1 \
  bash "${SCRIPTS_DIR}/uninstall-claude.sh" "$@"
}

# status-claude.sh を安全なテスト環境変数付きで実行する
run_status() {
  DOTFILES_DIR="${TEST_DOTFILES}" \
  CLAUDE_HOME="${TEST_HOME}/.claude" \
  HOME="${TEST_HOME}" \
  NO_COLOR=1 \
  bash "${SCRIPTS_DIR}/status-claude.sh" "$@"
}

# ---------------------------------------------------------------------------
# TRAP: テスト終了時に必ず cleanup を実行
# ---------------------------------------------------------------------------

cleanup() {
  teardown_test_env
}
trap cleanup EXIT

# ---------------------------------------------------------------------------
# テスト実行開始
# ---------------------------------------------------------------------------

printf "================================================================\n"
printf " Claude dotfiles install/uninstall テスト\n"
printf "================================================================\n"

# テスト環境を初期化
setup_test_env

# ===========================================================================
# 1. 基本インストールテスト
# ===========================================================================

describe "1. 基本インストールテスト"

reset_claude_home
run_install > /dev/null 2>&1

it "agents/ シンボリックリンクが作成される"
assert_exists "${TEST_HOME}/.claude/agents" \
  "~/.claude/agents が存在する"

it "agents/ が正しいターゲットを指すシンボリックリンクである"
assert_symlink \
  "${TEST_HOME}/.claude/agents" \
  "${TEST_DOTFILES}/claude/agents" \
  "~/.claude/agents -> dotfiles/claude/agents"

it "commands/ シンボリックリンクが作成される"
assert_exists "${TEST_HOME}/.claude/commands" \
  "~/.claude/commands が存在する"

it "commands/ が正しいターゲットを指すシンボリックリンクである"
assert_symlink \
  "${TEST_HOME}/.claude/commands" \
  "${TEST_DOTFILES}/claude/commands" \
  "~/.claude/commands -> dotfiles/claude/commands"

it "rules/ シンボリックリンクが作成される"
assert_exists "${TEST_HOME}/.claude/rules" \
  "~/.claude/rules が存在する"

it "rules/ が正しいターゲットを指すシンボリックリンクである"
assert_symlink \
  "${TEST_HOME}/.claude/rules" \
  "${TEST_DOTFILES}/claude/rules" \
  "~/.claude/rules -> dotfiles/claude/rules"

# ===========================================================================
# 2. 冪等性テスト
# ===========================================================================

describe "2. 冪等性テスト"

reset_claude_home
run_install > /dev/null 2>&1

# 2 回目の実行
install_output_2nd="$(run_install 2>&1)"

it "2 回目の実行で 'skip' が出力される"
if echo "${install_output_2nd}" | grep -q "skip"; then
  printf "  [PASS] %s: skip が出力された\n" "${CURRENT_TEST}"
  ((PASS++)) || true
else
  printf "  [FAIL] %s: skip が出力されなかった\n" "${CURRENT_TEST}"
  printf "         output: %s\n" "${install_output_2nd}"
  ((FAIL++)) || true
fi

it "2 回目実行後も agents/ シンボリックリンクが壊れていない"
assert_symlink \
  "${TEST_HOME}/.claude/agents" \
  "${TEST_DOTFILES}/claude/agents" \
  "2 回目後も agents/ が正しいリンク先を維持している"

it "2 回目実行後も commands/ シンボリックリンクが壊れていない"
assert_symlink \
  "${TEST_HOME}/.claude/commands" \
  "${TEST_DOTFILES}/claude/commands" \
  "2 回目後も commands/ が正しいリンク先を維持している"

it "2 回目実行後も rules/ シンボリックリンクが壊れていない"
assert_symlink \
  "${TEST_HOME}/.claude/rules" \
  "${TEST_DOTFILES}/claude/rules" \
  "2 回目後も rules/ が正しいリンク先を維持している"

# ===========================================================================
# 3. バックアップテスト
# ===========================================================================

describe "3. バックアップテスト"

reset_claude_home

# ~/.claude/agents/ を実ディレクトリとして作成し、内容を入れておく
mkdir -p "${TEST_HOME}/.claude/agents"
echo "# existing agent" > "${TEST_HOME}/.claude/agents/existing-agent.md"

run_install > /dev/null 2>&1

it "バックアップディレクトリが作成される"
assert_exists "${TEST_HOME}/.claude/backups" \
  "~/.claude/backups/ が存在する"

it "agents のバックアップが存在する"
backup_count="$(find "${TEST_HOME}/.claude/backups" -maxdepth 1 -name "agents.bak.*" -type d 2>/dev/null | wc -l)"
if [[ "${backup_count}" -ge 1 ]]; then
  printf "  [PASS] %s: agents.bak.* が %d 個存在する\n" "${CURRENT_TEST}" "${backup_count}"
  ((PASS++)) || true
else
  printf "  [FAIL] %s: agents.bak.* が見つからない\n" "${CURRENT_TEST}"
  ((FAIL++)) || true
fi

it "バックアップに元のファイルが保存されている"
latest_backup="$(find "${TEST_HOME}/.claude/backups" -maxdepth 1 -name "agents.bak.*" -type d 2>/dev/null | LC_ALL=C sort | tail -n 1)"
if [[ -n "${latest_backup}" ]]; then
  assert_contains \
    "${latest_backup}/existing-agent.md" \
    "# existing agent" \
    "バックアップ内に元のファイル内容が存在する"
else
  printf "  [FAIL] %s: バックアップが見つからないため確認不可\n" "${CURRENT_TEST}"
  ((FAIL++)) || true
fi

it "バックアップ後に agents/ がシンボリックリンクになっている"
assert_symlink \
  "${TEST_HOME}/.claude/agents" \
  "${TEST_DOTFILES}/claude/agents" \
  "バックアップ後に agents/ が正しいシンボリックリンクになった"

# ===========================================================================
# 4. アンインストールテスト
# ===========================================================================

describe "4. アンインストールテスト"

# 4a. バックアップなしのアンインストール

reset_claude_home
run_install > /dev/null 2>&1
run_uninstall > /dev/null 2>&1

it "アンインストール後に agents/ シンボリックリンクが削除される"
if [[ ! -L "${TEST_HOME}/.claude/agents" ]]; then
  printf "  [PASS] %s: agents/ シンボリックリンクが削除された\n" "${CURRENT_TEST}"
  ((PASS++)) || true
else
  printf "  [FAIL] %s: agents/ シンボリックリンクが残っている\n" "${CURRENT_TEST}"
  ((FAIL++)) || true
fi

it "アンインストール後に commands/ シンボリックリンクが削除される"
if [[ ! -L "${TEST_HOME}/.claude/commands" ]]; then
  printf "  [PASS] %s: commands/ シンボリックリンクが削除された\n" "${CURRENT_TEST}"
  ((PASS++)) || true
else
  printf "  [FAIL] %s: commands/ シンボリックリンクが残っている\n" "${CURRENT_TEST}"
  ((FAIL++)) || true
fi

it "アンインストール後に rules/ シンボリックリンクが削除される"
if [[ ! -L "${TEST_HOME}/.claude/rules" ]]; then
  printf "  [PASS] %s: rules/ シンボリックリンクが削除された\n" "${CURRENT_TEST}"
  ((PASS++)) || true
else
  printf "  [FAIL] %s: rules/ シンボリックリンクが残っている\n" "${CURRENT_TEST}"
  ((FAIL++)) || true
fi

# 4b. バックアップありのアンインストール（バックアップから復元）

reset_claude_home

# インストール前に実ディレクトリを作成（バックアップ対象）
mkdir -p "${TEST_HOME}/.claude/agents"
echo "# restore target" > "${TEST_HOME}/.claude/agents/restore-me.md"

run_install > /dev/null 2>&1
run_uninstall > /dev/null 2>&1

it "バックアップがある場合、アンインストール後に通常ディレクトリとして復元される"
if [[ -d "${TEST_HOME}/.claude/agents" ]] && [[ ! -L "${TEST_HOME}/.claude/agents" ]]; then
  printf "  [PASS] %s: agents/ が通常ディレクトリとして復元された\n" "${CURRENT_TEST}"
  ((PASS++)) || true
else
  printf "  [FAIL] %s: agents/ が期待通りに復元されていない\n" "${CURRENT_TEST}"
  ((FAIL++)) || true
fi

it "復元されたディレクトリにバックアップ前のファイルが存在する"
assert_contains \
  "${TEST_HOME}/.claude/agents/restore-me.md" \
  "# restore target" \
  "復元後にバックアップ前の内容が復元されている"

# ===========================================================================
# 5. DRY_RUN テスト
# ===========================================================================

describe "5. DRY_RUN テスト"

reset_claude_home
DRY_RUN=1 run_install > /dev/null 2>&1

it "DRY_RUN=1 では agents/ シンボリックリンクが作成されない"
assert_not_exists \
  "${TEST_HOME}/.claude/agents" \
  "DRY_RUN=1 後に agents/ が存在しない"

it "DRY_RUN=1 では commands/ シンボリックリンクが作成されない"
assert_not_exists \
  "${TEST_HOME}/.claude/commands" \
  "DRY_RUN=1 後に commands/ が存在しない"

it "DRY_RUN=1 では rules/ シンボリックリンクが作成されない"
assert_not_exists \
  "${TEST_HOME}/.claude/rules" \
  "DRY_RUN=1 後に rules/ が存在しない"

# DRY_RUN でバックアップ対象がある場合もファイルシステムを変更しない
reset_claude_home
mkdir -p "${TEST_HOME}/.claude/agents"
echo "# should not be moved" > "${TEST_HOME}/.claude/agents/dont-move-me.md"

DRY_RUN=1 run_install > /dev/null 2>&1

it "DRY_RUN=1 では既存の実ディレクトリが移動されない"
assert_exists \
  "${TEST_HOME}/.claude/agents/dont-move-me.md" \
  "DRY_RUN=1 後に元ファイルが変更されていない"

it "DRY_RUN=1 ではバックアップディレクトリが作成されない"
assert_not_exists \
  "${TEST_HOME}/.claude/backups" \
  "DRY_RUN=1 後に backups/ が作成されていない"

# ===========================================================================
# 6. ファイル追加の即時反映テスト
# ===========================================================================

describe "6. ファイル追加の即時反映テスト"

reset_claude_home
run_install > /dev/null 2>&1

# インストール後に dotfiles 側に新しいファイルを追加
echo "# new agent added after install" > "${TEST_DOTFILES}/claude/agents/new-agent.md"

it "インストール後に dotfiles 側に追加したファイルが ~/.claude/ 側から見える"
assert_exists \
  "${TEST_HOME}/.claude/agents/new-agent.md" \
  "新規追加ファイルがシンボリックリンク経由で参照できる"

it "追加ファイルの内容がシンボリックリンク経由で正しく読める"
assert_contains \
  "${TEST_HOME}/.claude/agents/new-agent.md" \
  "# new agent added after install" \
  "ファイル内容がシンボリックリンク経由で正しく読める"

# commands/ でも同様に確認
echo "# new command added after install" > "${TEST_DOTFILES}/claude/commands/new-command.md"

it "インストール後に dotfiles 側に追加した commands/ ファイルも即時反映される"
assert_exists \
  "${TEST_HOME}/.claude/commands/new-command.md" \
  "commands/ 側の新規ファイルもシンボリックリンク経由で参照できる"

# ---------------------------------------------------------------------------
# テスト結果サマリー
# ---------------------------------------------------------------------------

TOTAL=$((PASS + FAIL))

printf "\n================================================================\n"
printf " テスト結果サマリー\n"
printf "================================================================\n"
printf "  合計: %d\n" "${TOTAL}"
printf "  成功: %d\n" "${PASS}"
printf "  失敗: %d\n" "${FAIL}"
printf "================================================================\n"

if [[ "${FAIL}" -gt 0 ]]; then
  exit 1
else
  printf " 全テスト成功\n"
  exit 0
fi
