@echo off
set GIT="C:\Program Files\Git\bin\git.exe"

echo.
echo [INFO] Deploying Xinji to GitHub Pages
echo.

echo [INFO] Step 1: Check Git
%GIT% --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git not found at %GIT%
    exit /b 1
)
echo [OK] Git is installed

echo.
echo [INFO] Step 2: Initialize Git repo
if not exist ".git" (
    echo Initializing repo...
    %GIT% init
)
echo [OK] Git repo ready

echo.
echo [INFO] Step 3: Setup remote
%GIT% remote get-url origin >temp_remote.txt 2>&1
set /p remoteUrl=<temp_remote.txt
del temp_remote.txt 2>nul

if "%remoteUrl%"=="" (
    echo Adding remote...
    %GIT% remote add origin %1
) else (
    echo Remote exists: %remoteUrl%
    if not "%remoteUrl%"=="%1" (
        echo Updating remote URL...
        %GIT% remote set-url origin %1
    )
)
echo [OK] Remote configured

echo.
echo [INFO] Step 4: Create deploy dir
if exist "deploy-temp" rmdir /s /q "deploy-temp"
mkdir "deploy-temp"

echo.
echo [INFO] Step 5: Copy files
copy index.html "deploy-temp\" >nul
copy manifest.json "deploy-temp\" >nul
copy sw.js "deploy-temp\" >nul
copy test-api.html "deploy-temp\" >nul
if exist "icons" (
    xcopy /s /e /y "icons" "deploy-temp\icons\" >nul
)
echo [OK] Files copied

echo.
echo [INFO] Step 6: Push to GitHub
cd "deploy-temp"
%GIT% init
%GIT% checkout -b gh-pages
%GIT% add -A
%GIT% commit -m "Deploy xinji %date% %time%"
%GIT% push -f origin gh-pages
cd ..

echo.
echo [INFO] Step 7: Cleanup
rmdir /s /q "deploy-temp"

echo.
echo ========================================
echo Deploy SUCCESS!
echo ========================================
echo.
echo URL: https://TanJianXiang.github.io/MindTrace/
echo.
echo Note: GitHub Pages may take a few minutes to activate
echo.
pause