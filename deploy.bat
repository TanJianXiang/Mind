@echo off
echo.
echo [INFO] 开始部署心迹项目到GitHub Pages
echo.

echo [INFO] 步骤1: 检查Git
git --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Git未安装
    exit /b 1
)
echo [OK] Git已安装

echo.
echo [INFO] 步骤2: 初始化Git仓库
if not exist ".git" (
    echo 初始化仓库...
    git init
)
echo [OK] Git仓库就绪

echo.
echo [INFO] 步骤3: 配置远程仓库
git remote get-url origin >temp_remote.txt 2>&1
set /p remoteUrl=<temp_remote.txt
del temp_remote.txt

if "%remoteUrl%"=="" (
    echo 添加远程仓库...
    git remote add origin %1
) else (
    echo 远程仓库已存在: %remoteUrl%
    if not "%remoteUrl%"=="%1" (
        echo 更新远程仓库URL...
        git remote set-url origin %1
    )
)
echo [OK] 远程仓库配置完成

echo.
echo [INFO] 步骤4: 创建部署目录
if exist ".deploy-temp" rmdir /s /q ".deploy-temp"
mkdir ".deploy-temp"

echo.
echo [INFO] 步骤5: 复制文件
copy index.html ".deploy-temp\" >nul
copy manifest.json ".deploy-temp\" >nul
copy sw.js ".deploy-temp\" >nul
copy test-api.html ".deploy-temp\" >nul
if exist "icons" (
    xcopy /s /e /y "icons" ".deploy-temp\icons\" >nul
)
echo [OK] 文件复制完成

echo.
echo [INFO] 步骤6: 推送到GitHub
cd ".deploy-temp"
git init
git checkout -b gh-pages
git add -A
git commit -m "Deploy xinji %date% %time%"
git push -f origin gh-pages
cd ..

echo.
echo [INFO] 步骤7: 清理
rmdir /s /q ".deploy-temp"

echo.
echo ========================================
echo 部署成功!
echo ========================================
echo.
echo 访问地址: https://TanJianXiang.github.io/MindTrace/
echo.
echo 注意: GitHub Pages可能需要几分钟才能生效
echo.
pause