<#
.SYNOPSIS
部署心迹项目到GitHub Pages

.DESCRIPTION
将心迹项目构建并推送到GitHub仓库的gh-pages分支，实现自动部署到GitHub Pages

.PARAMETER RepositoryUrl
GitHub仓库URL，例如：https://github.com/用户名/仓库名.git

.PARAMETER Branch
部署目标分支，默认为gh-pages

.EXAMPLE
.\deploy.ps1 -RepositoryUrl "https://github.com/username/xinji.git"
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$RepositoryUrl,
    
    [string]$Branch = "gh-pages"
)

$ErrorActionPreference = "Stop"

function Write-Status {
    param([string]$Message)
    Write-Host "`n[$(Get-Date -Format 'HH:mm:ss')] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

try {
    Write-Status "开始部署心迹项目到GitHub Pages"
    
    Write-Status "步骤1: 检查Git是否安装"
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        throw "Git未安装，请先安装Git: https://git-scm.com/download/win"
    }
    Write-Success "Git已安装"
    
    Write-Status "步骤2: 检查当前目录"
    $currentDir = Get-Location
    Write-Host "当前目录: $currentDir"
    
    Write-Status "步骤3: 初始化Git仓库（如果尚未初始化）"
    if (-not (Test-Path ".git")) {
        Write-Host "初始化Git仓库..."
        git init
        Write-Success "Git仓库初始化完成"
    } else {
        Write-Success "Git仓库已存在"
    }
    
    Write-Status "步骤4: 配置Git用户信息"
    $gitUser = git config user.name
    $gitEmail = git config user.email
    
    if (-not $gitUser) {
        Write-Host "请输入Git用户名:"
        $userName = Read-Host
        git config user.name $userName
    }
    
    if (-not $gitEmail) {
        Write-Host "请输入Git邮箱:"
        $email = Read-Host
        git config user.email $email
    }
    Write-Success "Git用户信息配置完成"
    
    Write-Status "步骤5: 添加远程仓库"
    $remoteExists = git remote | Select-String "origin"
    if ($remoteExists) {
        $currentRemote = git remote get-url origin
        Write-Host "远程仓库已存在: $currentRemote"
        if ($currentRemote -ne $RepositoryUrl) {
            Write-Host "更新远程仓库URL..."
            git remote set-url origin $RepositoryUrl
        }
    } else {
        Write-Host "添加远程仓库..."
        git remote add origin $RepositoryUrl
    }
    Write-Success "远程仓库配置完成"
    
    Write-Status "步骤6: 创建部署临时目录"
    $deployDir = ".deploy"
    if (Test-Path $deployDir) {
        Remove-Item -Recurse -Force $deployDir
    }
    New-Item -ItemType Directory -Path $deployDir | Out-Null
    Write-Success "部署目录创建完成: $deployDir"
    
    Write-Status "步骤7: 复制项目文件到部署目录"
    $filesToCopy = @(
        "index.html",
        "manifest.json",
        "sw.js",
        "icons/",
        "test-api.html"
    )
    
    foreach ($file in $filesToCopy) {
        if (Test-Path $file) {
            if (Test-Path $file -PathType Container) {
                Copy-Item -Path $file -Destination $deployDir -Recurse -Force
            } else {
                Copy-Item -Path $file -Destination $deployDir -Force
            }
            Write-Host "  复制: $file"
        } else {
            Write-Host "  跳过（不存在）: $file"
        }
    }
    Write-Success "文件复制完成"
    
    Write-Status "步骤8: 切换到部署目录并创建提交"
    Set-Location $deployDir
    
    Write-Host "初始化部署仓库..."
    git init
    git checkout -b $Branch
    
    Write-Host "添加所有文件..."
    git add -A
    
    $commitMessage = "Deploy xinji $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host "创建提交: $commitMessage"
    git commit -m $commitMessage
    
    Write-Success "提交创建完成"
    
    Write-Status "步骤9: 推送到GitHub"
    Write-Host "推送到远程仓库..."
    git push -f origin $Branch
    
    Write-Success "推送完成"
    
    Write-Status "步骤10: 清理临时目录"
    Set-Location ..
    Remove-Item -Recurse -Force $deployDir
    Write-Success "临时目录清理完成"
    
    Write-Host "`n"
    Write-Success "部署成功！"
    Write-Host "`n访问地址: https://$($RepositoryUrl -replace 'https://github.com/','').github.io"
    Write-Host "`n注意：GitHub Pages可能需要几分钟才能生效"
    
} catch {
    Write-Error "部署失败: $_"
    Write-Host "`n错误详情:"
    Write-Host $_.Exception.Message
    exit 1
}