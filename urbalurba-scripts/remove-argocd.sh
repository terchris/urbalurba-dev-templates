#!/bin/bash
# File: urbalurba-scripts/remove-argocd.sh
# Description: Removes your project from ArgoCD
# Run this on your host machine (macOS/Linux), NOT in the devcontainer

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print a colored message
print_message() {
  local color=$1
  local message=$2
  echo -e "${color}${message}${NC}"
}

# Print a success message
print_success() {
  print_message "${GREEN}" "✅ $1"
}

# Print an error message
print_error() {
  print_message "${RED}" "❌ $1"
}

# Print a warning message
print_warning() {
  print_message "${YELLOW}" "⚠️ $1"
}

# Print an info message
print_info() {
  print_message "${BLUE}" "ℹ️ $1"
}

# Function to handle errors
handle_error() {
  print_error "$1"
  exit 1
}

# Extract Git info on the host machine
GITHUB_REMOTE=$(git remote get-url origin)
REPO_NAME=$(basename -s .git "$GITHUB_REMOTE")

if [[ -z "$REPO_NAME" ]]; then
  handle_error "Could not determine repo name"
fi

print_success "Detected repository: $REPO_NAME"

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    handle_error "Docker is not installed or not in PATH"
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    handle_error "Docker daemon is not running"
fi

# Check if provision-host container is running or image exists
if docker ps | grep -q provision-host; then
    print_success "provision-host container is running"
    # Use existing container instead of starting a new one
    print_info "Running removal using existing provision-host container..."
    docker exec -it provision-host \
        /bin/bash -c "REPO_NAME=\"$REPO_NAME\" /mnt/urbalurbadisk/scripts/argocd/argocd-remove-app.sh" || {
        handle_error "Docker exec failed"
    }
elif docker images provision-host | grep -q provision-host; then
    print_success "provision-host image found"
    # Run a new container
    print_info "Running removal using new provision-host container..."
    docker run --rm -it \
        -v $HOME/.kube:/root/.kube \
        -e REPO_NAME="$REPO_NAME" \
        provision-host \
        /bin/bash -c "/mnt/urbalurbadisk/scripts/argocd/argocd-remove-app.sh" || {
        handle_error "Docker container execution failed"
    }
else
    handle_error "provision-host Docker image not found and no container running. The urbalurba-infrastructure must be installed first."
fi

print_success "Removal process completed."
print_info "If you want to recreate the application, run ./urbalurba-scripts/register-argocd.sh"

