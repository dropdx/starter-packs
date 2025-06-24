#!/bin/sh

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Configuration ---
ROOT_DIR="$(dirname "$(dirname "$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0" | sed 's/\/[^/]*\/[^/]*$//')")")"
TEMPLATES_DIR="${ROOT_DIR}/templates"
STARTERS_DIR="${ROOT_DIR}/starters"

# --- Functions ---

# Function to check for fzf dependency
check_fzf() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: 'fzf' is required for interactive template selection." >&2
    echo "Please install it: https://github.com/junegunn/fzf#installation" >&2
    exit 1
  fi
}

# --- Main Script Logic ---

echo "🚀 dropdx Starter Scaffolding Tool 🚀"
echo "-------------------------------------"

# Check if fzf is installed
check_fzf

# Ensure starters directory exists
mkdir -p "${STARTERS_DIR}"

# 1. List available templates and prompt for selection using fzf
echo "Please select a template for your new starter:"
# Get template names
template_names=$(find "${TEMPLATES_DIR}" -maxdepth 1 -mindepth 1 -type d -printf "%f\n" | sort)

# Use fzf for interactive selection
# -1 ensures fzf exits immediately upon selection for single choice
# --prompt "Select template: " customizes the prompt
selected_template_name=$(echo "$template_names" | fzf --height 15 --reverse --layout=reverse --border --prompt="Select template: ")

if [ -z "$selected_template_name" ]; then
  echo "No template selected. Exiting."
  exit 1
fi

selected_template_path="${TEMPLATES_DIR}/${selected_template_name}"
echo "Selected template: '$selected_template_name'"

# 2. Prompt for a name for the new starter
NEW_STARTER_NAME=""
while [ -z "$NEW_STARTER_NAME" ]; do
  printf "Enter a name for the new starter (e.g., my-awesome-starter): "
  read -r name_input

  sanitized_name=$(echo "$name_input" | tr '[:upper:]' '[:lower:]' | tr -c 'a-z0-9-' '-')
  sanitized_name=$(echo "$sanitized_name" | sed -e 's/^-*//' -e 's/-*$//' -e 's/--/-/g')

  if [ -z "$sanitized_name" ]; then
    echo "Invalid name. Please enter a non-empty name using alphanumeric characters or hyphens."
  elif [ -d "${STARTERS_DIR}/${sanitized_name}" ]; then
    echo "Error: A starter named '${sanitized_name}' already exists. Please choose a different name."
  else
    NEW_STARTER_NAME="$sanitized_name"
  fi
done

NEW_STARTER_PATH="${STARTERS_DIR}/${NEW_STARTER_NAME}"

echo "Creating new starter '$NEW_STARTER_NAME' from template '$selected_template_name'..."

# 3. Copy the selected template folder
cp -R "${selected_template_path}" "${NEW_STARTER_PATH}"
echo "template copied to '${NEW_STARTER_PATH}'."

# 4. Update name into the newly created package.json file
PACKAGE_JSON_FILE="${NEW_STARTER_PATH}/package.json"

if [ -f "$PACKAGE_JSON_FILE" ]; then
  TEMP_PACKAGE_JSON="${PACKAGE_JSON_FILE}.tmp"
  sed "s|\(\"name\": \"@dropdx/starter-\)[^\"]*\"|\1${NEW_STARTER_NAME}\"|" "${PACKAGE_JSON_FILE}" >"${TEMP_PACKAGE_JSON}"
  mv "${TEMP_PACKAGE_JSON}" "${PACKAGE_JSON_FILE}"

  echo "Updated 'name' in '${PACKAGE_JSON_FILE}' to '@dropdx/starter-${NEW_STARTER_NAME}'."
else
  echo "Warning: No package.json found in '${NEW_STARTER_PATH}'. Skipping name update."
fi

echo "-------------------------------------"
echo "✅ New starter '${NEW_STARTER_NAME}' created successfully!"
echo "You can find it at: ${NEW_STARTER_PATH}"
echo "Next steps: cd ${NEW_STARTER_PATH} && pnpm install (if applicable)"
