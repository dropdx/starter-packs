#!/bin/zsh

# ssh-keys-loader.zsh

# This script provides a function `ssh_keys_loader` designed to be sourced
# into a Zsh shell environment (e.g., .zshrc). Its primary purpose is to:
#   1. Ensure an `ssh-agent` is running. It attempts to start one if not
#      already active.
#   2. Automatically find and add SSH private keys from the user's `$HOME/.ssh`
#      directory to the `ssh-agent`. It avoids adding keys that are already
#      loaded and skips common non-key files (like public keys, known_hosts, etc.).

# Function to start ssh-agent if not running and load SSH private keys.
#
# Behavior:
#   - Detects the current shell (Zsh) to determine the optimal `ssh-agent` startup command.
#     It prefers `exec ssh-agent zsh` if this function is likely called at session start
#     (e.g., from .zshrc). Otherwise, it uses `eval "$(ssh-agent -s)"`.
#   - Checks if `ssh-agent` is already running via `SSH_AGENT_PID`. If not,
#     it starts one.
#   - Scans `$HOME/.ssh` for private key files, excluding common non-private key files.
#   - For each private key found, it checks if the key is already loaded in the agent.
#   - If a key is not loaded, it attempts to add it using `ssh-add`.
#   - Outputs a message if it fails to load a specific key.
#
# Pre-requisites:
#   - `ssh-agent`, `ssh-add`, `ssh-keygen`, `find`, `kill`, `awk`, `grep` commands
#     should be available in the PATH.
#
# Arguments:
#   None.
#
# Returns:
#   0 if the function completes its attempt to check/start agent and load keys.
#     This includes cases where no keys are found or some keys fail to load.
#   1 if the `$HOME/.ssh` directory does not exist or if required commands are missing.
#
# Example:
#   To use this function, source this script in your ~/.zshrc and then call the function:
#
#   # In ~/.zshrc:
#   source /path/to/your/scripts/ssh-keys-autoload.zsh
#   ssh_keys_loader

_auto_install_missing_commands_ubuntu() {
  local missing_cmds=("$@")
  if [ ${#missing_cmds[@]} -eq 0 ]; then
    return 0
  fi

  echo "Attempting to install missing commands for ssh_keys_loader..." >&2
  echo "You may be prompted for your sudo password." >&2

  local packages_to_install=()
  for cmd in "${missing_cmds[@]}"; do
    case "$cmd" in
    ssh-agent | ssh-add | ssh-keygen) packages_to_install+=("openssh-client") ;;
    find) packages_to_install+=("findutils") ;;
    kill) packages_to_install+=("procps") ;;
    awk) packages_to_install+=("gawk") ;;
    grep) packages_to_install+=("grep") ;;
    *) echo "Warning: No known package for '$cmd' on Ubuntu. Skipping automatic installation." >&2 ;;
    esac
  done

  # Remove duplicates and ensure 'sudo' is available for apt
  packages_to_install=($(echo "${packages_to_install[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

  if [ ${#packages_to_install[@]} -gt 0 ]; then
    # Perform apt update first, then install
    if ! sudo apt update; then
      echo "Error: Failed to update apt package lists. Cannot proceed with installation." >&2
      return 1
    fi
    if ! sudo apt install -y "${packages_to_install[@]}"; then
      echo "Error: Failed to install one or more required packages. Please check for errors above." >&2
      return 1
    fi
    echo "Successfully attempted to install missing packages." >&2
    return 0
  else
    echo "No packages identified for automatic installation." >&2
    return 1 # No packages to install, but still indicate an issue if this path is reached without installation.
  fi
}

ssh_keys_loader() {
  # --- Command existence checks ---
  local required_commands=(ssh-agent ssh-add ssh-keygen find kill awk grep)
  local missing_commands=()

  for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
      missing_commands+=("$cmd")
    fi
  done

  if [ ${#missing_commands[@]} -ne 0 ]; then
    # Attempt to auto-install
    if _auto_install_missing_commands_ubuntu "${missing_commands[@]}"; then
      # Re-check if commands are now available after attempted installation
      echo "Re-checking commands after attempted installation..." >&2
      local remaining_missing_commands=()
      for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
          remaining_missing_commands+=("$cmd")
        fi
      done
      if [ ${#remaining_missing_commands[@]} -eq 0 ]; then
        echo "All required commands are now available. Proceeding." >&2
      else
        echo "Still missing some commands after attempted installation: ${remaining_missing_commands[*]}" >&2
        echo "Please install them manually." >&2
        return 1
      fi
    else
      echo "Automatic installation failed or was skipped. Please install missing commands manually." >&2
      return 1 # Exit if auto-installation fails
    fi
  fi
  # --- End of command existence checks ---

  local ssh_agent_cmd

  # Use 'exec ssh-agent zsh' if in Zsh. This replaces the current shell process.
  # Suitable if this function is called from .zshrc to start a session.
  ssh_agent_cmd='exec ssh-agent zsh'

  # Check if ssh-agent is already running by inspecting SSH_AGENT_PID
  # and verifying the process exists.
  if [ -z "$SSH_AGENT_PID" ] || ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
    # Start ssh-agent using the auto-detected or default command.
    # `eval` is used here because ssh-agent -s outputs shell commands
    # to set environment variables (SSH_AUTH_SOCK, SSH_AGENT_PID).
    eval "$ssh_agent_cmd"
  fi

  local ssh_dir="$HOME/.ssh"
  if [ ! -d "$ssh_dir" ]; then # Check if the SSH directory exists.
    echo "SSH directory $ssh_dir does not exist. Exiting."
    return 1
  fi

  # Find private keys: exclude public keys, known_hosts, *.old, *.txt, *.cert, *.pub, *.pem
  local key_files=()
  while IFS= read -r -d $'\0' file; do
    # Populate array with null-terminated find results for safety with special filenames.
    key_files+=("$file")
  done < <(find "$ssh_dir" -type f ! -name "*.pub" ! -name "known_hosts*" ! -name "*.old" ! -name "*.txt" ! -name "*.cert" ! -name "*.pem" -print0)

  if [ ${#key_files[@]} -eq 0 ]; then
    echo "No private SSH keys found in $ssh_dir."
    return 0 # No keys found is not an error condition for this function.
  fi

  for key in "${key_files[@]}"; do
    # Check if the key is already loaded in the agent.
    # This is done by comparing the fingerprint of the key file
    # with the fingerprints of keys listed by `ssh-add -l`.
    # `ssh-keygen -lf "$key"` gets the fingerprint of the key file.
    # `awk '{print $2}'` extracts the fingerprint string.
    # `ssh-add -l` lists fingerprints of loaded keys.
    # `grep -q` quietly checks if the key's fingerprint is in the list.
    # stderr is redirected to /dev/null to suppress errors if a file is not a valid key
    # or if ssh-add -l has no keys.
    if ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')"; then
      continue # Key already loaded, skip to the next one.
    fi
    ssh-add "$key" 2>/dev/null || echo "Failed to load key: $key"
  done

  return 0
}
