param(
    [Parameter(Mandatory=$true)]
    [string]$RepositoryUrl,
    
    [string]$Branch = "gh-pages"
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 开始部署心迹项目到GitHub Pages" -ForegroundColor Cyan

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 步骤1: 检查Git" -ForegroundColor Cyan
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if (-not $gitCmd) {
    Write-Host "Git未安装，请先安装" -ForegroundColor Red
    exit 1
}
Write-Host "Git已安装: $(git --version)" -ForegroundColor Green

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 步骤2: 初始化Git仓库" -ForegroundColor Cyan
if (-not (Test-Path ".git")) {
    Write-Host "初始化仓库..."
    git init
}
Write-Host "Git仓库就绪" -ForegroundColor Green

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 步骤3: 配置远程仓库" -ForegroundColor Cyan
$remoteUrl = git remote get-url origin 2>$null
if ($remoteUrl) {
    Write-Host "远程仓库已存在: $remoteUrl"
    if ($remoteUrl -ne $RepositoryUrl) {
        git remote set-url origin $RepositoryUrl
        Write-Host "已更新远程仓库" -ForegroundColor Green
    }
} else {
    git remote add origin $RepositoryUrl
    Write-Host "已添加远程仓库" -ForegroundColor Green
}

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 步骤4: 创建部署目录" -ForegroundColor Cyan
$deployDir = ".deploy-temp"
if (Test-Path $deployDir) {
    Remove-Item -Recurse -Force $deployDir
}
New-Item -ItemType Directory -Path $deployDir | Out-Null

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 步骤5: 复制文件" -ForegroundColor Cyan
$files = @("index.html", "manifest.json", "sw.js", "test-api.html")
Copy-Item -Path "index.html" -Destination $deployDir -Force
Copy-Item -Path "manifest.json" -Destination $deployDir -Force
Copy-Item -Path "sw.js" -Destination $deployDir -Force
Copy-Item -Path "test-api.html" -Destination $deployDir -Force
if (Test-Path "icons") {
    Copy-Item -Path "icons" -Destination $deployDir -Recurse -Force
}
Write-Host "文件复制完成" -ForegroundColor Green

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 步骤6: 推送到GitHub" -ForegroundColor Cyan
Set-Location $deployDir
git init -q
git checkout -q -b $Branch
git add -A
$commitMsg = "Deploy xinji $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
git commit -q -m $commitMsg
git push -q -f origin $Branch
Set-Location ..

Write-Host "[$(Get-Date -Format 'HH:mm:ss')] 步骤7: 清理" -ForegroundColor Cyan
Remove-Item -Recurse -Force $deployDir

Write-Host ""
Write-Host "部署成功!" -ForegroundColor Green
$repoPath = $RepositoryUrl -replace 'https://github.com/',''
Write-Host "访问地址: https://$repoPath.github.io" -ForegroundColor Cyan
Write-Host ""
Write-Host "注意: GitHub Pages可能需要几分钟才能生效" -ForegroundColor Yellow