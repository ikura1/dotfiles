#!/usr/bin/env bash
# scripts/status-claude.sh -- 現在の symlink 状態を表示する
#
# Usage:
#   ./scripts/status-claude.sh
#
# 処理フロー:
#   1. CLAUDE_MANAGED_DIRS をループ:
#      a. get_link_status() で状態取得
#      b. count_files() でファイル数取得
#      c. 1 行で状態を表示
#   2. backups/ のエントリ数を表示
#   3. サマリー("N/3 managed by dotfiles")

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

main() {
  setup_colors

  log_header "Symlink status"
  printf "\n"

  local managed=0
  local total="${#CLAUDE_MANAGED_DIRS[@]}"

  for dir in "${CLAUDE_MANAGED_DIRS[@]}"; do
    local link_path="${CLAUDE_HOME}/${dir}"
    local src_path="${CLAUDE_SRC_DIR}/${dir}"
    local display_link="${link_path/#$HOME/~}"
    local display_src="${src_path/#$HOME/~}"

    local status
    status="$(get_link_status "${dir}")"

    # ファイル数取得（symlink の場合はリンク先を解決）
    local file_count=0
    if [[ "${status}" == "correct" ]]; then
      file_count="$(count_files "${src_path}")"
    elif [[ "${status}" == "directory" ]]; then
      file_count="$(count_files "${link_path}")"
    fi

    case "${status}" in
      correct)
        printf "  ${COLOR_GREEN}%-40s${COLOR_RESET} ${COLOR_GREEN}[OK]${COLOR_RESET}  %s files\n" \
          "${display_link} -> ${display_src}" "${file_count}"
        ((managed++)) || true
        ;;
      wrong_target)
        local actual_target
        actual_target="$(readlink "${link_path}")"
        printf "  ${COLOR_YELLOW}%-40s${COLOR_RESET} ${COLOR_YELLOW}[!!]${COLOR_RESET}  wrong target: %s\n" \
          "${display_link}" "${actual_target}"
        ;;
      directory)
        printf "  ${COLOR_DIM}%-40s${COLOR_RESET} ${COLOR_DIM}[--]${COLOR_RESET}  %s file(s)\n" \
          "${display_link} (not a symlink - plain directory)" "${file_count}"
        ;;
      missing)
        printf "  ${COLOR_DIM}%-40s${COLOR_RESET} ${COLOR_DIM}[--]${COLOR_RESET}  (does not exist)\n" \
          "${display_link}"
        ;;
      other)
        printf "  ${COLOR_RED_BOLD}%-40s${COLOR_RESET} ${COLOR_RED_BOLD}[!!]${COLOR_RESET}  unexpected file type\n" \
          "${display_link}"
        ;;
    esac

    if [[ "${VERBOSE:-0}" == "1" ]] && [[ "${status}" == "correct" ]]; then
      printf "       readlink: %s\n" "$(readlink "${link_path}")"
    fi
  done

  printf "\n"

  # バックアップ一覧と件数を表示
  local backup_count=0
  if [[ -d "${CLAUDE_BACKUP_DIR}" ]]; then
    backup_count="$(ls -1 "${CLAUDE_BACKUP_DIR}" 2>/dev/null | wc -l | tr -d ' ')"
  fi
  local display_backup="${CLAUDE_BACKUP_DIR/#$HOME/~}"
  printf "  Backups: %s (%s entries)\n" "${display_backup}" "${backup_count}"

  printf "\n"
  log_header "${managed}/${total} managed by dotfiles."
}

main "$@"
