@echo off
chcp 65001 >nul
echo ==============================================
echo         心迹 AI 版本恢复工具
echo ==============================================
echo.

if not exist "backups" (
    echo 错误: 未找到备份目录！
    pause
    exit /b 1
)

echo 可用备份列表:
echo ----------------------------------------------
setlocal enabledelayedexpansion
set "i=1"
for /d %%d in (backups\*) do (
    echo !i!. %%~nxd
    set "backup[!i!]=%%d"
    set /a "i+=1"
)
set /a "max=i-1"
endlocal & set "max=%max%"

echo ----------------------------------------------
set /p "choice=请输入要恢复的备份序号: "

setlocal enabledelayedexpansion
if not defined backup[%choice%] (
    echo 无效的选择！
    pause
    exit /b 1
)

set "sourceDir=!backup[%choice%]!"
endlocal & set "sourceDir=%sourceDir%"

echo.
echo 确认恢复以下备份:
echo   %sourceDir%
echo.
set "confirm=n"
set /p "confirm=确认恢复? (y/N): "
if /i not "%confirm%"=="y" (
    echo 已取消恢复操作。
    pause
    exit /b 0
)

echo.
echo 正在恢复文件...

if exist "%sourceDir%\index.html" (
    copy "%sourceDir%\index.html" "index.html" /Y >nul
    echo   index.html 已恢复
) else (
    echo   index.html 不存在于备份中
)

if exist "%sourceDir%\manifest.json" (
    copy "%sourceDir%\manifest.json" "manifest.json" /Y >nul
    echo   manifest.json 已恢复
)

if exist "%sourceDir%\sw.js" (
    copy "%sourceDir%\sw.js" "sw.js" /Y >nul
    echo   sw.js 已恢复
)

if exist "%sourceDir%\test-api.html" (
    copy "%sourceDir%\test-api.html" "test-api.html" /Y >nul
    echo   test-api.html 已恢复
)

echo.
echo ==============================================
echo         恢复完成！
echo ==============================================
echo.
pause