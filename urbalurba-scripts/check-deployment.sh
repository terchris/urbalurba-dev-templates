#!/bin/bash
# File: urbalurba-scripts/check-deployment.sh
# Description: Checks the status of your application deployment
# Run this on your host machine (macOS/Linux), NOT in the devcontainer

# Get repository name from current directory
REPO_NAME=$(basename -s .git $(git remote get-url origin | sed 's/\.git$//'))

# Run the provision-host container to check status
docker run --rm -it \
  -v $HOME/.kube:/root/.kube \
  norwegianredcross/provision-host:latest \
  /bin/bash -c "kubectl get pods -n $REPO_NAME && \
  echo '' && \
  echo 'Application status:' && \
  kubectl get application $REPO_NAME -n argocd -o jsonpath='{.status.sync.status}' && \
  echo '' && \
  echo 'Health status:' && \
  kubectl get application $REPO_NAME -n argocd -o jsonpath='{.status.health.status}' && \
  echo '' && \
  echo 'Latest logs:' && \
  kubectl logs -n $REPO_NAME -l app=app --tail=20"