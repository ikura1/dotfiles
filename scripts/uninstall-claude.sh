#!/usr/bin/env bash
# scripts/uninstall-claude.sh -- symlink を解除し、バックアップを復元する
#
# Usage:
#   ./scripts/uninstall-claude.sh
#   DRY_RUN=1 ./scripts/uninstall-claude.sh    # 変更内容を事前確認
#
# 処理フロー:
#   1. CLAUDE_MANAGED_DIRS をループ:
#      a. symlink でなければスキップ
#      b. remove_symlink() で symlink 削除
#      c. find_latest_backup() でバックアップを検索
#      d. バックアップあり -> mv で復元
#      e. バックアップなし -> mkdir -p で空ディレクトリ作成
#   2. サマリー出力

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# uninstall_dir(dir_name)
#   1 ディレクトリ分のアンインストール処理を行う
#   戻り値(stdout): "skipped" | "restored" | "emptied"
uninstall_dir() {
  local dir_name="${1}"
  local link_path="${CLAUDE_HOME}/${dir_name}"
  local display_link="${link_path/#$HOME/~}"

  local status
  status="$(get_link_status "${dir_name}")"

  if [[ "${status}" != "correct" ]] && [[ "${status}" != "wrong_target" ]]; then
    # symlink でなければスキップ（通常ディレクトリや missing の場合）
    log_action "skip" "${display_link}   (not a symlink, skipping)" >&2
    echo "skipped"
    return 0
  fi

  # symlink 削除
  remove_symlink "${link_path}" >&2

  # バックアップから復元
  local latest_backup
  latest_backup="$(find_latest_backup "${dir_name}")"

  if [[ -n "${latest_backup}" ]]; then
    local display_backup="${latest_backup/#$HOME/~}"
    log_action "restore" "${display_link}   <- ${display_backup}" >&2
    if [[ "${DRY_RUN:-0}" != "1" ]]; then
      mv "${latest_backup}" "${link_path}"
    fi
    echo "restored"
    return 0
  else
    log_action "empty" "${display_link}   (no backup found, created empty directory)" >&2
    if [[ "${DRY_RUN:-0}" != "1" ]]; then
      mkdir -p "${link_path}"
    fi
    echo "emptied"
    return 0
  fi
}

main() {
  setup_colors

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_header "DRY RUN - no changes will be made"
  else
    log_header "Uninstalling Claude dotfiles..."
  fi
  printf "\n"

  local restored=0
  local emptied=0
  local skipped=0
  local errors=0

  for dir in "${CLAUDE_MANAGED_DIRS[@]}"; do
    local result
    if result="$(uninstall_dir "${dir}")"; then
      case "${result}" in
        restored)
          ((restored++)) || true
          ;;
        emptied)
          ((emptied++)) || true
          ;;
        *)
          ((skipped++)) || true
          ;;
      esac
    else
      ((errors++)) || true
    fi
  done

  printf "\n"

  if [[ "${errors}" -gt 0 ]]; then
    log_action "error" "${errors} error(s) occurred. Check output above."
    return 1
  fi

  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_header "DRY RUN complete. Run without DRY_RUN=1 to apply."
  else
    local parts=()
    if [[ "${restored}" -gt 0 ]]; then
      parts+=("${restored} directories restored")
    fi
    if [[ "${emptied}" -gt 0 ]]; then
      parts+=("${emptied} created empty")
    fi
    if [[ "${skipped}" -gt 0 ]]; then
      parts+=("${skipped} skipped")
    fi
    if [[ ${#parts[@]} -eq 0 ]]; then
      log_header "Done. Nothing to uninstall."
    else
      log_header "Done. $(IFS=', '; echo "${parts[*]}")."
    fi
  fi
}

main "$@"
