@echo off
REM File: urbalurba-scripts/check-deployment.bat
REM Description: Checks the status of your application deployment
REM Run this on your host machine (Windows), NOT in the devcontainer

REM Get repository name using git command
for /f "tokens=*" %%i in ('git remote get-url origin') do set REMOTE_URL=%%i
for /f "tokens=*" %%i in ('echo %REMOTE_URL% ^| sed "s/\.git$//" ^| sed "s/.*\/\(.*\)/\1/"') do set REPO_NAME=%%i

REM Run the provision-host container to check status
docker run --rm -it ^
  -v %USERPROFILE%\.kube:/root/.kube ^
  norwegianredcross/provision-host:latest ^
  /bin/bash -c "kubectl get pods -n %REPO_NAME% && echo '' && echo 'Application status:' && kubectl get application %REPO_NAME% -n argocd -o jsonpath='{.status.sync.status}' && echo '' && echo 'Health status:' && kubectl get application %REPO_NAME% -n argocd -o jsonpath='{.status.health.status}' && echo '' && echo 'Latest logs:' && kubectl logs -n %REPO_NAME% -l app=app --tail=20"