#!/bin/bash
# File: /scripts/register-app.sh in the provision-host container

# Use the environment variables passed from the host
# Instead of trying to detect from a mounted repo

# Validate required environment variables
if [ -z "$GITHUB_USERNAME" ] || [ -z "$REPO_NAME" ] || [ -z "$GITHUB_PAT" ]; then
  echo "❌ Error: Required environment variables missing!"
  echo "Make sure GITHUB_USERNAME, REPO_NAME, and GITHUB_PAT are set."
  exit 1
fi

echo "Registering $GITHUB_USERNAME/$REPO_NAME with ArgoCD..."

# Create namespace for the application
kubectl create namespace $REPO_NAME --dry-run=client -o yaml | kubectl apply -f -

# Create GitHub credentials secret
kubectl create secret generic github-$REPO_NAME \
  --namespace=argocd \
  --from-literal=username=$GITHUB_USERNAME \
  --from-literal=password=$GITHUB_PAT \
  --dry-run=client -o yaml | kubectl apply -f -

# Create ArgoCD Application resource
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: $REPO_NAME
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/$GITHUB_USERNAME/$REPO_NAME
    targetRevision: HEAD
    path: manifests
    usernameSecret:
      name: github-$REPO_NAME
      key: username
    passwordSecret:
      name: github-$REPO_NAME
      key: password
  destination:
    server: https://kubernetes.default.svc
    namespace: $REPO_NAME
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

echo "✅ Application $REPO_NAME registered successfully!"
echo ""
echo "🔍 To check deployment status, use the ArgoCD UI:"
echo "kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "Then visit https://localhost:8080 in your browser"
echo ""
echo "🌐 To access your application, set up local DNS with:"
echo "- On macOS/Linux: sudo ./urbalurba-scripts/setup-local-dns.sh"
echo "- On Windows (as Administrator): urbalurba-scripts/setup-local-dns.bat"
echo ""
echo "Then visit http://$REPO_NAME.local in your browser"