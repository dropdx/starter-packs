#!/usr/bin/env zsh

list_all() {
  local dir="."
  local show_full_path=0
  local only_files=0
  local only_dirs=0

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      cat <<EOF
Usage: list_all [options] [directory]

List all files and directories (including hidden, excluding '.' and '..').

Options:
  -h, --help        Show this help message
  --full-path       Print absolute paths instead of just names
  --only-files      Show only regular files
  --only-dirs       Show only directories

Examples:
  list_all
  list_all --full-path ~/.config
  list_all --only-dirs /etc
EOF
      return 0
      ;;
    --full-path)
      show_full_path=1
      shift
      ;;
    --only-files)
      only_files=1
      shift
      ;;
    --only-dirs)
      only_dirs=1
      shift
      ;;
    -*)
      print -u2 "list_all: Unknown option '$1'"
      return 1
      ;;
    *)
      dir="$1"
      shift
      ;;
    esac
  done

  # Validate directory
  if [[ ! -d "$dir" ]]; then
    print -u2 "list_all: '$dir' is not a directory"
    return 1
  fi

  local -a find_args=()
  if ((only_files)) && ((only_dirs)); then
    # Both flags set - no output
    return 0
  elif ((only_files)); then
    find_args+=("-type" "f")
  elif ((only_dirs)); then
    find_args+=("-type" "d")
  fi

  if ((show_full_path)); then
    find "$dir" -mindepth 1 -maxdepth 1 "${find_args[@]}" -print0 |
      xargs -0 -n1 realpath | sort -V
  else
    find "$dir" -mindepth 1 -maxdepth 1 "${find_args[@]}" -printf '%f\0' |
      sort -z -V | tr '\0' '\n'
  fi
}
