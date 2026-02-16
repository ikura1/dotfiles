#!/bin/bash
# scripts/lib.sh -- Claude dotfiles 共通ライブラリ
#
# 全スクリプトから source される共通関数群。
# Usage: source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# --- 定数 ---
DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
CLAUDE_HOME="${CLAUDE_HOME:-${HOME}/.claude}"
CLAUDE_SRC_DIR="${DOTFILES_DIR}/claude"
CLAUDE_BACKUP_DIR="${CLAUDE_HOME}/backups"
CLAUDE_MANAGED_DIRS=(agents commands rules)

# --- 環境変数（オプション） ---
# DRY_RUN=1  : 変更を行わない
# VERBOSE=1  : 詳細ログ
# NO_COLOR=1 : カラー無効化

# --- カラー変数（setup_colors() で初期化される） ---
COLOR_GREEN=""
COLOR_CYAN=""
COLOR_YELLOW=""
COLOR_BLUE=""
COLOR_DIM=""
COLOR_RED_BOLD=""
COLOR_RESET=""

# setup_colors()
#   TTY 判定と NO_COLOR を考慮してカラー変数を設定する
#   呼び出し: 各スクリプトの先頭で 1 回
setup_colors() {
  if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]]; then
    COLOR_GREEN="\e[32m"
    COLOR_CYAN="\e[36m"
    COLOR_YELLOW="\e[33m"
    COLOR_BLUE="\e[34m"
    COLOR_DIM="\e[2m"
    COLOR_RED_BOLD="\e[1;31m"
    COLOR_RESET="\e[0m"
  fi
}

# log_action(action, message)
#   "[action] message" 形式で出力する
#   action に応じたカラーを自動適用
#   DRY_RUN=1 時は action を "would ${action}" に変換
log_action() {
  local action="${1}"
  local message="${2}"
  local color=""

  # DRY_RUN=1 時は "would " プレフィックスを付加
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    action="would ${action}"
    color="${COLOR_DIM}"
  else
    case "${action}" in
      create)     color="${COLOR_GREEN}" ;;
      skip)       color="${COLOR_CYAN}" ;;
      backup)     color="${COLOR_YELLOW}" ;;
      restore)    color="${COLOR_BLUE}" ;;
      remove)     color="${COLOR_YELLOW}" ;;
      empty)      color="${COLOR_CYAN}" ;;
      done)       color="${COLOR_GREEN}" ;;
      error)      color="${COLOR_RED_BOLD}" ;;
      *)          color="" ;;
    esac
  fi

  printf "  ${color}[%-14s]${COLOR_RESET} %s\n" "${action}" "${message}"
}

# log_error(message)
#   "[claude] ERROR: message" を stderr に赤太字で出力
log_error() {
  local message="${1}"
  printf "${COLOR_RED_BOLD}[claude] ERROR: %s${COLOR_RESET}\n" "${message}" >&2
}

# log_header(message)
#   "[claude] message" をセクション開始行として出力
log_header() {
  local message="${1}"
  printf "[claude] %s\n" "${message}"
}

# log_summary(created, skipped, backed_up)
#   "[claude] Done. ..." サマリー行を出力
log_summary() {
  local created="${1}"
  local skipped="${2}"
  local backed_up="${3}"

  if [[ "${created}" -eq 0 ]] && [[ "${skipped}" -ge 0 ]]; then
    if [[ "${skipped}" -gt 0 ]] && [[ "${created}" -eq 0 ]]; then
      printf "[claude] Done. Nothing to do. All symlinks are up to date.\n"
      return
    fi
  fi

  local parts=()
  if [[ "${created}" -gt 0 ]]; then
    parts+=("${created} symlinks created")
  fi
  if [[ "${skipped}" -gt 0 ]]; then
    parts+=("${skipped} skipped")
  fi
  if [[ "${backed_up}" -gt 0 ]]; then
    parts+=("${backed_up} backups saved")
    printf "[claude] Done. %s.\n         Backups: %s/\n" \
      "$(IFS=', '; echo "${parts[*]}")" \
      "${CLAUDE_BACKUP_DIR}"
    return
  fi

  if [[ ${#parts[@]} -eq 0 ]]; then
    printf "[claude] Done.\n"
  else
    printf "[claude] Done. %s.\n" "$(IFS=', '; echo "${parts[*]}")"
  fi
}

# --- ファイルシステム操作 ---

# ensure_dir(path)
#   mkdir -p を DRY_RUN 考慮で実行
ensure_dir() {
  local path="${1}"
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_action "create" "directory ${path}"
  else
    mkdir -p "${path}"
  fi
}

# backup_dir(dir_name)
#   dir_name に対応する CLAUDE_HOME のディレクトリを CLAUDE_BACKUP_DIR に
#   タイムスタンプ付きで移動する
#   戻り値(stdout): バックアップ先のパス
#   DRY_RUN=1 時はログのみ
backup_dir() {
  local dir_name="${1}"
  local src_path="${CLAUDE_HOME}/${dir_name}"
  local timestamp
  timestamp="$(date +%Y%m%d_%H%M%S)"
  local backup_path="${CLAUDE_BACKUP_DIR}/${dir_name}.bak.${timestamp}"

  if [[ -e "${backup_path}" ]]; then
    log_error "Backup destination already exists.\n\n  Path: ${backup_path}\n\n  Fix: Remove or rename the conflicting backup directory.\n       rm -rf ${backup_path}"
    return 1
  fi

  log_action "backup" "~/.claude/${dir_name}   -> ${backup_path}"

  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    mkdir -p "${CLAUDE_BACKUP_DIR}"
    mv "${src_path}" "${backup_path}"
  fi

  echo "${backup_path}"
}

# create_symlink(src, dest)
#   ln -s を DRY_RUN 考慮で実行
create_symlink() {
  local src="${1}"
  local dest="${2}"
  local display_dest="${dest/#$HOME/~}"
  local display_src="${src/#$HOME/~}"

  log_action "create" "${display_dest}   -> ${display_src}"

  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    ln -s "${src}" "${dest}"
  fi
}

# remove_symlink(path)
#   symlink であることを確認してから rm
#   通常ディレクトリの場合はエラー
remove_symlink() {
  local path="${1}"
  local display_path="${path/#$HOME/~}"

  if [[ ! -L "${path}" ]]; then
    log_error "Not a symlink: ${display_path}\n\n  Fix: Remove manually if needed.\n       rm -rf ${path}"
    return 1
  fi

  log_action "remove" "${display_path}   (symlink removed)"

  if [[ "${DRY_RUN:-0}" != "1" ]]; then
    rm "${path}"
  fi
}

# --- 状態判定 ---

# is_correct_symlink(link_path, expected_target)
#   link_path が expected_target を指す symlink か判定
#   戻り値: 0 (正しい) / 1 (不一致または非 symlink)
is_correct_symlink() {
  local link_path="${1}"
  local expected_target="${2}"

  if [[ ! -L "${link_path}" ]]; then
    return 1
  fi

  local actual_target
  actual_target="$(readlink "${link_path}")"

  if [[ "${actual_target}" == "${expected_target}" ]]; then
    return 0
  else
    return 1
  fi
}

# get_link_status(dir_name)
#   指定ディレクトリの状態を判定する
#   戻り値(stdout): "correct" | "wrong_target" | "directory" | "missing" | "other"
#
#   各状態の意味:
#     correct      : 正しい symlink が設定済み
#     wrong_target : 別のパスへの symlink（競合）
#     directory    : 通常ディレクトリ（バックアップ対象）
#     missing      : 存在しない（新規作成対象）
#     other        : ファイル・パイプ等の場合はエラーとして中断
get_link_status() {
  local dir_name="${1}"
  local link_path="${CLAUDE_HOME}/${dir_name}"
  local expected_target="${CLAUDE_SRC_DIR}/${dir_name}"

  if [[ -L "${link_path}" ]]; then
    if is_correct_symlink "${link_path}" "${expected_target}"; then
      echo "correct"
    else
      echo "wrong_target"
    fi
  elif [[ -d "${link_path}" ]]; then
    echo "directory"
  elif [[ ! -e "${link_path}" ]]; then
    echo "missing"
  else
    # ファイル・パイプ等の場合はエラーとして中断
    echo "other"
  fi
}

# find_latest_backup(dir_name)
#   dir_name の最新バックアップパスを返す（LC_ALL=C sort で安定ソート）
#   バックアップがない場合は空文字列
find_latest_backup() {
  local dir_name="${1}"

  # LC_ALL=C を明示してロケール依存のソートを避ける
  local latest
  latest="$(find "${CLAUDE_BACKUP_DIR}" -maxdepth 1 -name "${dir_name}.bak.*" -type d 2>/dev/null \
    | LC_ALL=C sort | tail -n 1)"

  echo "${latest}"
}

# count_files(dir_path)
#   ディレクトリ内のファイル数を返す（再帰なし）
count_files() {
  local dir_path="${1}"

  if [[ ! -d "${dir_path}" ]]; then
    echo "0"
    return
  fi

  # シンボリックリンク先もディレクトリとして解決して数える
  local count
  count="$(find "${dir_path}" -maxdepth 1 -type f | wc -l)"
  echo "${count}"
}

# --- バリデーション ---

# validate_source_dir(dir_name)
#   CLAUDE_SRC_DIR/dir_name が存在するか確認
#   存在しない場合はエラーメッセージを出力して return 1
validate_source_dir() {
  local dir_name="${1}"
  local src_path="${CLAUDE_SRC_DIR}/${dir_name}"

  if [[ ! -d "${src_path}" ]]; then
    local display_path="${src_path/#$HOME/~}"
    log_error "Source directory not found.\n\n  Expected: ${display_path}/\n  Found:    (does not exist)\n\n  Fix: Create the directory and add files to it.\n       mkdir -p ${src_path}"
    return 1
  fi
}

# validate_dotfiles_dir()
#   DOTFILES_DIR が存在するか確認
validate_dotfiles_dir() {
  if [[ ! -d "${DOTFILES_DIR}" ]]; then
    local display_path="${DOTFILES_DIR/#$HOME/~}"
    log_error "Dotfiles directory not found.\n\n  Expected: ${display_path}/\n  Found:    (does not exist)\n\n  Fix: Run make from within the dotfiles repository.\n       cd ${DOTFILES_DIR} && make install-claude"
    return 1
  fi
}
