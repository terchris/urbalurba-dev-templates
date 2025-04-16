#!/bin/bash
# File: urbalurba-scripts/setup-local-dns.sh
# Description: Sets up local DNS entry for your application
# Run this on your host machine (macOS/Linux), NOT in the devcontainer

# Get repository name from current directory
REPO_NAME=$(basename -s .git $(git remote get-url origin | sed 's/\.git$//'))

# Get Traefik IP address
TRAEFIK_IP=$(docker run --rm -it \
  -v $HOME/.kube:/root/.kube \
  norwegianredcross/provision-host:latest \
  /bin/bash -c "kubectl get svc -n kube-system traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}'")

if [ -z "$TRAEFIK_IP" ]; then
  echo "⚠️ Could not determine Traefik IP address. Using localhost."
  TRAEFIK_IP="127.0.0.1"
fi

# Check if entry already exists
if grep -q "$REPO_NAME.local" /etc/hosts; then
  echo "🔄 Updating hosts file entry for $REPO_NAME.local"
  sudo sed -i '' "/$REPO_NAME.local/d" /etc/hosts
else
  echo "➕ Adding new hosts file entry for $REPO_NAME.local"
fi

# Add entry to hosts file
echo "Adding $TRAEFIK_IP $REPO_NAME.local to hosts file..."
echo "$TRAEFIK_IP $REPO_NAME.local" | sudo tee -a /etc/hosts > /dev/null

echo "✅ Host $REPO_NAME.local configured to point to $TRAEFIK_IP"
echo "You can now access your application at: http://$REPO_NAME.local"