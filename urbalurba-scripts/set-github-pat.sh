#!/bin/bash
# File: urbalurba-scripts/set-github-pat.sh
# Description: Sets your GitHub Personal Access Token (PAT) as an environment variable
# Run this on your host machine (macOS/Linux), NOT in the devcontainer
#
# Features:
# - Accepts token as an argument or prompts for it securely
# - Detects current shell and persists GITHUB_PAT in the proper profile file
# - Colored output and error handling

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_message() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

print_success() { print_message "${GREEN}" "✅ $1"; }
print_error() { print_message "${RED}" "❌ $1"; }
print_warning() { print_message "${YELLOW}" "⚠️ $1"; }
print_info() { print_message "${BLUE}" "ℹ️ $1"; }
print_section() { echo ""; print_message "${CYAN}" "== $1 =="; }

# Handle errors
handle_error() {
  print_error "$1"
  exit 1
}

print_section "GitHub Personal Access Token Setup"

# Check if a token was passed
if [ -z "$1" ]; then
  print_info "No token passed as argument."
  read -sp "Enter your GitHub Personal Access Token: " GITHUB_PAT
  echo ""
else
  GITHUB_PAT="$1"
fi

# Validate the token
if [ -z "$GITHUB_PAT" ]; then
  handle_error "No GitHub PAT provided. Cannot proceed."
fi

# Set it for current shell session
export GITHUB_PAT="$GITHUB_PAT"
print_success "GITHUB_PAT exported for current session."

# Determine which profile file to persist to
if [[ "$SHELL" == */zsh ]]; then
  PROFILE="$HOME/.zshrc"
elif [[ "$SHELL" == */bash ]]; then
  PROFILE="$HOME/.bash_profile"
else
  PROFILE="$HOME/.profile"
fi

# Add to profile only if not already there
if grep -q "export GITHUB_PAT=" "$PROFILE"; then
  print_warning "GITHUB_PAT already set in $PROFILE. Updating it..."
  sed -i.bak '/export GITHUB_PAT=/d' "$PROFILE"
else
  print_info "Adding GITHUB_PAT to $PROFILE..."
fi

echo "export GITHUB_PAT=$GITHUB_PAT" >> "$PROFILE"
print_success "GITHUB_PAT saved to $PROFILE"

print_info "You may need to restart your terminal or run 'source $PROFILE' to use it."
