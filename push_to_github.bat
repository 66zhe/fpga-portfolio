@echo off
cd /d "%~dp0"
setlocal

set "GIT=D:\Program Files\Git\bin\git.exe"
if not exist "%GIT%" set "GIT=git"

echo ============================================
echo   Push  fpga-portfolio  to  GitHub
echo   Repo dir: %CD%
echo ============================================
echo.
echo  [Tip] Your GitHub username is shown at:
echo        github.com  -  click your avatar (top-right)
echo        Signed in as:  ^<username^>
echo        or just look at the URL: github.com/USERNAME
echo.

set /p GHUSER=Enter your GitHub username then press Enter:

if "%GHUSER%"=="" (
  echo.
  echo [X] Username is empty. Aborted.
  pause
  exit /b 1
)

echo.
echo [1/4] setting remote: git@github.com:%GHUSER%/fpga-portfolio.git
"%GIT%" remote remove origin 2>nul
"%GIT%" remote add origin git@github.com:%GHUSER%/fpga-portfolio.git
if errorlevel 1 (
  echo [X] git remote add FAILED. Check the username.
  pause
  exit /b 1
)

echo [2/4] renaming branch to main
"%GIT%" branch -M main
if errorlevel 1 (
  echo [X] git branch FAILED.
  pause
  exit /b 1
)

echo [3/4] testing SSH connection to GitHub
echo       (if asked "Are you sure you want to continue connecting?"
echo        type  yes  and press Enter)
"%GIT%" -c core.sshCommand="ssh -o StrictHostKeyChecking=accept-new" ls-remote origin >nul 2>&1
if errorlevel 1 (
  echo.
  echo [!] Cannot reach GitHub over SSH.
  echo     - Did you add the public key at github.com/settings/keys ?
  echo     - Or port 22 is blocked - then use the HTTPS method instead:
  echo       git remote set-url origin https://github.com/%GHUSER%/fpga-portfolio.git
  echo.
  pause
  exit /b 1
)
echo       SSH OK ^(public key accepted^)

echo [4/4] pushing...
"%GIT%" push -u origin main
if errorlevel 1 (
  echo.
  echo [X] push FAILED. Read the message above, or try HTTPS method.
  pause
  exit /b 1
)

echo.
echo ============================================
echo   DONE!  Open:
echo   https://github.com/%GHUSER%/fpga-portfolio
echo ============================================
echo.
pause
