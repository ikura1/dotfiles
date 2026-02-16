#!/usr/bin/env bash
# scripts/install-claude.sh -- Claude dotfiles のシンボリックリンクを作成する
#
# Usage:
#   ./scripts/install-claude.sh
#   DRY_RUN=1 ./scripts/install-claude.sh    # 変更内容を事前確認
#   VERBOSE=1 ./scripts/install-claude.sh    # 詳細ログ
#
# 処理フロー:
#   1. validate_dotfiles_dir() でリポジトリの存在確認
#   2. CLAUDE_MANAGED_DIRS をループ:
#      a. validate_source_dir() でソースの存在確認
#      b. get_link_status() で現在の状態を判定
#      c. "correct"      -> skip
#      d. "directory"    -> backup_dir() してから create_symlink()
#      e. "wrong_target" -> エラー出力（手動対応を促す）
#      f. "missing"      -> create_symlink()
#      g. "other"        -> エラー出力（中断）
#   3. CLAUDE-BASE.md を ~/.claude/CLAUDE.md にコピー
#   4. log_summary() でサマリー出力

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# install_dir(dir_name)
#   1 ディレクトリ分のインストール処理を行う
#   エラー発生時は return 1
install_dir() {
  local dir_name="${1}"
  local link_path="${CLAUDE_HOME}/${dir_name}"
  local src_path="${CLAUDE_SRC_DIR}/${dir_name}"
  local display_link="${link_path/#$HOME/~}"
  local display_src="${src_path/#$HOME/~}"

  # ソースディレクトリの存在確認
  if ! validate_source_dir "${dir_name}"; then
    return 1
  fi

  local status
  status="$(get_link_status "${dir_name}")"

  case "${status}" in
    correct)
      log_action "skip" "${display_link}   (already symlinked correctly)"
      return 0
      ;;
    directory)
      if ! backup_dir "${dir_name}" > /dev/null; then
        return 1
      fi
      create_symlink "${src_path}" "${link_path}"
      return 0
      ;;
    wrong_target)
      local actual_target
      actual_target="$(readlink "${link_path}")"
      log_error "Symlink conflict detected.\n\n  Path:     ${display_link}\n  Current:  -> ${actual_target}  (unexpected target)\n  Expected: -> ${display_src}\n\n  Fix: Remove the existing symlink manually and re-run.\n       rm ${link_path}\n       make install-claude"
      return 1
      ;;
    missing)
      create_symlink "${src_path}" "${link_path}"
      return 0
      ;;
    other)
      log_error "Unexpected file type at ${display_link}.\n\n  Fix: Remove the file manually and re-run.\n       rm ${link_path}\n       make install-claude"
      return 1
      ;;
  esac
}

main() {
  setup_colors

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_header "DRY RUN - no changes will be made"
  else
    log_header "Installing Claude dotfiles..."
  fi
  printf "\n"

  # リポジトリ存在確認
  if ! validate_dotfiles_dir; then
    exit 1
  fi

  # ~/.claude ディレクトリ作成
  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    mkdir -p "${CLAUDE_HOME}"
  fi

  local errors=0
  local created=0
  local skipped=0
  local backed_up=0

  for dir in "${CLAUDE_MANAGED_DIRS[@]}"; do
    local status_before
    status_before="$(get_link_status "${dir}")"

    # エラーが起きても後続を続行
    if install_dir "${dir}"; then
      local status_after
      status_after="$(get_link_status "${dir}")"
      case "${status_before}" in
        correct)
          ((skipped++)) || true
          ;;
        directory)
          ((backed_up++)) || true
          ((created++)) || true
          ;;
        missing)
          ((created++)) || true
          ;;
      esac
    else
      ((errors++)) || true
    fi
  done

  # CLAUDE-BASE.md を ~/.claude/CLAUDE.md にコピー（既に存在する場合はスキップ）
  local dotfiles_claude_md="${DOTFILES_DIR}/CLAUDE-BASE.md"
  local claude_md="${CLAUDE_HOME}/CLAUDE.md"
  if [[ -f "${dotfiles_claude_md}" ]]; then
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
      if [[ -f "${claude_md}" ]]; then
        log_action "skip" "CLAUDE.md already exists"
      else
        log_action "create" "~/.claude/CLAUDE.md   (copy from CLAUDE-BASE.md)"
      fi
    else
      if [[ -f "${claude_md}" ]]; then
        log_action "skip" "CLAUDE.md already exists"
      else
        cp "${dotfiles_claude_md}" "${claude_md}"
        log_action "create" "CLAUDE.md"
      fi
    fi
  fi

  printf "\n"

  # エラーサマリー表示
  if [[ "${errors}" -gt 0 ]]; then
    log_action "error" "${errors} error(s) occurred. Check output above."
    return 1
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_header "DRY RUN complete. Run without DRY_RUN=1 to apply."
  else
    log_summary "${created}" "${skipped}" "${backed_up}"
  fi
}

main "$@"
