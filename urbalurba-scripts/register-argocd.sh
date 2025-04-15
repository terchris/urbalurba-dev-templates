#!/bin/bash
# File: urbalurba-scripts/register-argocd.sh
# Description: Registers your project with ArgoCD for automatic deployment
# Run this on your host machine (macOS/Linux), NOT in the devcontainer

# Extract Git info on the host machine
GITHUB_REMOTE=$(git remote get-url origin)
GITHUB_USERNAME=$(echo "$GITHUB_REMOTE" | sed -n 's/.*github.com[:/]\(.*\)\/.*/\1/p')
REPO_NAME=$(basename -s .git "$GITHUB_REMOTE")

if [[ -z "$GITHUB_USERNAME" || -z "$REPO_NAME" ]]; then
  echo "❌ Could not determine GitHub username or repo name"
  exit 1
fi

echo "✅ Detected repository: $GITHUB_USERNAME/$REPO_NAME"

# Prompt for GitHub PAT if not set
if [ -z "$GITHUB_PAT" ]; then
  read -sp "Enter your GitHub Personal Access Token: " GITHUB_PAT
  echo ""
fi

# Run the provision-host container with extracted info as parameters
echo "📦 Running registration using provision-host container..."
docker run --rm -it \
  -v $HOME/.kube:/root/.kube \
  -e GITHUB_PAT="$GITHUB_PAT" \
  -e GITHUB_USERNAME="$GITHUB_USERNAME" \
  -e REPO_NAME="$REPO_NAME" \
  norwegianredcross/provision-host:latest \
  /bin/bash -c "/scripts/register-app.sh"

echo "✅ Registration process completed."