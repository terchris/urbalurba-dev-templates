#!/bin/bash
# File: urbalurba-scripts/register-argocd.sh
# Description: Registers your project with ArgoCD for automatic deployment
# Run this on your host machine (macOS/Linux), NOT in the devcontainer
#
# Improved version with:
# - Better error handling
# - Progress indicators
# - Domain suffix configuration (.localhost instead of .local)
# - Better validation of prerequisites
# - Colored output for better readability

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

# Print a section header
print_section() {
  echo ""
  print_message "${CYAN}" "== $1 =="
}

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to handle errors
handle_error() {
  print_error "$1"
  exit 1
}

# We don't need a spinner - we want to see the full output from the Docker commands

# Domain suffix configuration - Use .localhost for Traefik
DOMAIN_SUFFIX="localhost"

# Default timeout in seconds
DEFAULT_TIMEOUT=300

print_section "Urbalurba ArgoCD Registration Tool"

# Check for required tools
if ! command_exists git; then
  handle_error "Git is not installed or not in PATH. Please install Git."
fi

# Extract Git info on the host machine
GITHUB_REMOTE=$(git remote get-url origin)
if [ -z "$GITHUB_REMOTE" ]; then
  handle_error "No Git remote found. Please make sure you're in a Git repository with a remote."
fi

GITHUB_USERNAME=$(echo "$GITHUB_REMOTE" | sed -n 's/.*github.com[:/]\(.*\)\/.*/\1/p')
REPO_NAME=$(basename -s .git "$GITHUB_REMOTE")

if [[ -z "$GITHUB_USERNAME" || -z "$REPO_NAME" ]]; then
  handle_error "Could not determine GitHub username or repo name."
fi

print_success "Detected repository: $GITHUB_USERNAME/$REPO_NAME"
print_info "GitHub username: $GITHUB_USERNAME"
print_info "Domain suffix: .$DOMAIN_SUFFIX"

# Prompt for GitHub PAT if not set
if [ -z "$GITHUB_PAT" ]; then
  print_info "GitHub Personal Access Token (PAT) not found in environment."
  read -sp "Enter your GitHub Personal Access Token: " GITHUB_PAT
  echo ""
  if [ -z "$GITHUB_PAT" ]; then
    handle_error "GitHub PAT is required for repository access."
  fi
else
  print_success "GitHub PAT is configured in environment"
fi

# Optionally accept a timeout parameter
WAIT_TIMEOUT=${1:-$DEFAULT_TIMEOUT}
print_info "Using timeout: $WAIT_TIMEOUT seconds"

# Check if Docker is available
if ! command_exists docker; then
    handle_error "Docker is not installed or not in PATH. Please install Docker."
fi

# Check if Docker daemon is running
if ! docker info &> /dev/null; then
    handle_error "Docker daemon is not running. Please start Docker."
fi

print_section "Checking for provision-host container"

# Check if provision-host container is running or image exists
if docker ps | grep -q provision-host; then
    print_success "provision-host container is running"
    # Use existing container instead of starting a new one
    print_info "Running registration using existing provision-host container..."
    
    # Execute the registration script in the container with the custom domain suffix
    docker exec -it provision-host \
        /bin/bash -c "GITHUB_PAT=\"$GITHUB_PAT\" GITHUB_USERNAME=\"$GITHUB_USERNAME\" REPO_NAME=\"$REPO_NAME\" DOMAIN_SUFFIX=\"$DOMAIN_SUFFIX\" WAIT_TIMEOUT=\"$WAIT_TIMEOUT\" /mnt/urbalurbadisk/scripts/argocd/argocd-register-app.sh"
    
    # Check if the command was successful
    if [ $? -ne 0 ]; then
        handle_error "Docker exec failed. See the error message above."
    fi
elif docker images provision-host | grep -q provision-host; then
    print_success "provision-host image found"
    # Run a new container
    print_info "Running registration using new provision-host container..."
    
    # Run the container with the custom domain suffix
    docker run --rm -it \
        -v $HOME/.kube:/root/.kube \
        -e GITHUB_PAT="$GITHUB_PAT" \
        -e GITHUB_USERNAME="$GITHUB_USERNAME" \
        -e REPO_NAME="$REPO_NAME" \
        -e DOMAIN_SUFFIX="$DOMAIN_SUFFIX" \
        -e WAIT_TIMEOUT="$WAIT_TIMEOUT" \
        provision-host \
        /bin/bash -c "/mnt/urbalurbadisk/scripts/argocd/argocd-register-app.sh"
    
    # Check if the command was successful
    if [ $? -ne 0 ]; then
        handle_error "Docker container execution failed. See the error message above."
    fi
else
    handle_error "provision-host Docker image not found and no container running. The urbalurba-infrastructure must be installed first."
fi

print_section "Deployment Summary"
print_success "Registration process completed."
print_info "Your application will be available at: http://$REPO_NAME.$DOMAIN_SUFFIX"
print_info "To access via port forwarding: kubectl port-forward svc/$REPO_NAME-service -n $REPO_NAME 8000:80"

print_section "Additional Commands"
echo "# Check the status of your pods:"
echo "kubectl get pods -n $REPO_NAME"
echo ""
echo "# View application logs:"
echo "kubectl logs -n $REPO_NAME deployment/$REPO_NAME-deployment"
echo ""
echo "# Delete the application if needed:"
echo "kubectl delete application $REPO_NAME -n argocd"