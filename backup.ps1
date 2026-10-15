$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupDir = "backups\v1.0_$timestamp"

Write-Host "=============================================="
Write-Host "         Xinji AI Version Backup Tool"
Write-Host "=============================================="
Write-Host ""
Write-Host "Creating backup directory: $backupDir"

New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

Write-Host ""
Write-Host "Backing up files..."

Copy-Item "index.html" "$backupDir\" -Force
Write-Host "  index.html"

Copy-Item "manifest.json" "$backupDir\" -Force
Write-Host "  manifest.json"

Copy-Item "sw.js" "$backupDir\" -Force
Write-Host "  sw.js"

if (Test-Path "test-api.html") {
    Copy-Item "test-api.html" "$backupDir\" -Force
    Write-Host "  test-api.html"
}

Write-Host ""
Write-Host "=============================================="
Write-Host "         Backup Complete!"
Write-Host "=============================================="
Write-Host "Backup path: $backupDir"
Write-Host ""
Write-Host "Files:"
Get-ChildItem $backupDir | Select-Object -ExpandProperty Name
Write-Host ""
Read-Host "Press Enter to continue"