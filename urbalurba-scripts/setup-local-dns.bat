@echo off
REM File: urbalurba-scripts/setup-local-dns.bat
REM Description: Sets up local DNS entry for your application
REM Run this as Administrator on your host machine (Windows), NOT in the devcontainer

REM Get repository name using git command
for /f "tokens=*" %%i in ('git remote get-url origin') do set REMOTE_URL=%%i
for /f "tokens=*" %%i in ('echo %REMOTE_URL% ^| sed "s/\.git$//" ^| sed "s/.*\/\(.*\)/\1/"') do set REPO_NAME=%%i

REM Get Traefik IP address
for /f "tokens=*" %%i in ('docker run --rm -v %USERPROFILE%\.kube:/root/.kube norwegianredcross/provision-host:latest /bin/bash -c "kubectl get svc -n kube-system traefik -o jsonpath=''{.status.loadBalancer.ingress[0].ip}''"') do set TRAEFIK_IP=%%i

if "%TRAEFIK_IP%" == "" (
  echo ⚠️ Could not determine Traefik IP address. Using localhost.
  set TRAEFIK_IP=127.0.0.1
)

REM Check if entry already exists and remove it
findstr /c:"%REPO_NAME%.local" %WINDIR%\System32\drivers\etc\hosts > nul
if %errorlevel% equ 0 (
  echo 🔄 Updating hosts file entry for %REPO_NAME%.local
  type %WINDIR%\System32\drivers\etc\hosts | findstr /v /c:"%REPO_NAME%.local" > %TEMP%\hosts.new
  copy /Y %TEMP%\hosts.new %WINDIR%\System32\drivers\etc\hosts > nul
) else (
  echo ➕ Adding new hosts file entry for %REPO_NAME%.local
)

REM Add new entry to hosts file
echo %TRAEFIK_IP% %REPO_NAME%.local >> %WINDIR%\System32\drivers\etc\hosts

echo ✅ Host %REPO_NAME%.local configured to point to %TRAEFIK_IP%
echo You can now access your application at: http://%REPO_NAME%.local