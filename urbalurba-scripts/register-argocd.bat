@echo off
REM File: urbalurba-scripts/register-argocd.bat
REM Description: Registers your project with ArgoCD for automatic deployment
REM Run this on your host machine (Windows), NOT in the devcontainer

echo 🚀 Registering your project with ArgoCD...

REM Extract Git info on the host machine
for /f "tokens=*" %%i in ('git remote get-url origin') do set GITHUB_REMOTE=%%i
for /f "tokens=*" %%i in ('echo %GITHUB_REMOTE% ^| sed "s/.*github.com[:/]\(.*\)\/.*/\1/"') do set GITHUB_USERNAME=%%i
for /f "tokens=*" %%i in ('echo %GITHUB_REMOTE% ^| sed "s/.*\/\(.*\)\.git/\1/"') do set REPO_NAME=%%i

echo ✅ Detected repository: %GITHUB_USERNAME%/%REPO_NAME%

REM Prompt for GitHub PAT if not provided
if "%GITHUB_PAT%"=="" (
  set /p GITHUB_PAT=Enter your GitHub Personal Access Token: 
)

REM Run the provision-host container with extracted info as parameters
echo 📦 Running registration using provision-host container...
docker run --rm -it ^
  -v %USERPROFILE%\.kube:/root/.kube ^
  -e GITHUB_PAT="%GITHUB_PAT%" ^
  -e GITHUB_USERNAME="%GITHUB_USERNAME%" ^
  -e REPO_NAME="%REPO_NAME%" ^
  norwegianredcross/provision-host:latest ^
  /bin/bash -c "/scripts/register-app.sh"

echo ✅ Registration process completed.