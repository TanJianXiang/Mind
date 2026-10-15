@echo off
chcp 65001 >nul

set "year=%date:~0,4%"
set "month=%date:~5,2%"
set "day=%date:~8,2%"
set "hour=%time:~0,2%"
if "%hour:~0,1%"==" " set "hour=0%hour:~1,1%"
set "minute=%time:~3,2%"
set "second=%time:~6,2%"
set "timestamp=%year%%month%%day%_%hour%%minute%%second%"
set "backupDir=backups\v1.0_%timestamp%"

echo ==============================================
echo         心迹 AI 版本备份工具
echo ==============================================
echo.
echo 创建备份目录: %backupDir%
mkdir "%backupDir%" 2>nul

echo.
echo 正在备份文件...

copy "index.html" "%backupDir%\" /Y
copy "manifest.json" "%backupDir%\" /Y
copy "sw.js" "%backupDir%\" /Y

if exist "test-api.html" copy "test-api.html" "%backupDir%\" /Y

echo.
echo ==============================================
echo         备份完成！
echo ==============================================
echo 备份路径: %backupDir%
echo.
echo 文件列表:
dir "%backupDir%" /B
echo.
pause