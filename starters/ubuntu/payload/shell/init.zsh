#!/usr/bin/env zsh
#
# init.zsh
#
# Zsh init script:
# 1) Source all *.zsh and *.sh files inside all subdirectories (one level)
# 2) Source all *.zsh and *.sh files in the root directory (excluding itself)
#
# Usage: source this from your zshrc

# Determine the directory this script resides in (works for sourced scripts)
if [[ -n ${ZSH_EVAL_CONTEXT} && ${ZSH_EVAL_CONTEXT} == *:file ]]; then
  init_dir="${(%):-%x}"
  init_dir="${init_dir:h}"
else
  init_dir="${0:A:h}"
fi

# Source *.zsh and *.sh files inside subdirectories
for subdir in "$init_dir"/*(/N); do
  echo "[init.zsh] Entering directory: $subdir"
  for file in "${subdir}"/*(.N); do
    case "$file" in
      *.zsh|*.sh)
        echo "[init.zsh] Sourcing: $file"
        source "$file"
        ;;
    esac
  done
done

# Source *.zsh and *.sh files in root directory excluding init.zsh itself
for file in "$init_dir"/*(.N); do
  [[ "$file" == "$init_dir/init.zsh" ]] && continue
  case "$file" in
    *.zsh|*.sh)
      echo "[init.zsh] Sourcing: $file"
      source "$file"
      ;;
  esac
done
