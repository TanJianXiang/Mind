Write-Host "=============================================="
Write-Host "         Xinji AI Version Restore Tool"
Write-Host "=============================================="
Write-Host ""

if (-not (Test-Path "backups")) {
    Write-Host "Error: Backup directory not found!"
    Read-Host "Press Enter to continue"
    exit 1
}

$backups = Get-ChildItem -Path "backups" -Directory | Sort-Object LastWriteTime -Descending

if ($backups.Count -eq 0) {
    Write-Host "Error: No backups found!"
    Read-Host "Press Enter to continue"
    exit 1
}

Write-Host "Available backups:"
Write-Host "----------------------------------------------"

for ($i = 0; $i -lt $backups.Count; $i++) {
    $date = $backups[$i].LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
    Write-Host ("{0,3}. {1,-40} ({2})" -f ($i + 1), $backups[$i].Name, $date)
}

Write-Host "----------------------------------------------"

do {
    $choice = Read-Host "Enter backup number to restore"
    if (-not [int]::TryParse($choice, [ref]$null)) {
        Write-Host "Please enter a valid number!"
        continue
    }
    $index = [int]$choice - 1
    if ($index -lt 0 -or $index -ge $backups.Count) {
        Write-Host "Number out of range!"
        continue
    }
    break
} while ($true)

$sourceDir = $backups[$index].FullName

Write-Host ""
Write-Host "Confirm restore from:"
Write-Host "  $sourceDir"
Write-Host ""

$confirm = Read-Host "Confirm restore? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Restore cancelled."
    Read-Host "Press Enter to continue"
    exit 0
}

Write-Host ""
Write-Host "Restoring files..."

if (Test-Path "$sourceDir\index.html") {
    Copy-Item "$sourceDir\index.html" "index.html" -Force
    Write-Host "  index.html restored"
} else {
    Write-Host "  index.html not found in backup"
}

if (Test-Path "$sourceDir\manifest.json") {
    Copy-Item "$sourceDir\manifest.json" "manifest.json" -Force
    Write-Host "  manifest.json restored"
}

if (Test-Path "$sourceDir\sw.js") {
    Copy-Item "$sourceDir\sw.js" "sw.js" -Force
    Write-Host "  sw.js restored"
}

if (Test-Path "$sourceDir\test-api.html") {
    Copy-Item "$sourceDir\test-api.html" "test-api.html" -Force
    Write-Host "  test-api.html restored"
}

Write-Host ""
Write-Host "=============================================="
Write-Host "         Restore Complete!"
Write-Host "=============================================="
Write-Host ""
Read-Host "Press Enter to continue"