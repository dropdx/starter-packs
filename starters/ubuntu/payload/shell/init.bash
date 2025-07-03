#!/usr/bin/env bash
#
# init.bash
#
# Bash init script:
# 1) Source all *.bash and *.sh files inside all subdirectories (one level)
# 2) Source all *.bash and *.sh files in the root directory (excluding itself)
#
# Usage: source this from your bashrc

init_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source *.bash and *.sh files inside subdirectories
for subdir in "$init_dir"/*/; do
  [[ -d "$subdir" ]] || continue
  for file in "$subdir"*; do
    [[ -f "$file" ]] || continue
    case "$file" in
    *.bash | *.sh)
      # shellcheck source=/dev/null
      source "$file"
      ;;
    esac
  done
done

# Source *.bash and *.sh files in root directory excluding init.bash itself
for file in "$init_dir"/*; do
  [[ -f "$file" ]] || continue
  [[ "$file" == "$init_dir/init.bash" ]] && continue
  case "$file" in
  *.bash | *.sh)
    # shellcheck source=/dev/null
    source "$file"
    ;;
  esac
done
