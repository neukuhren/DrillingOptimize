# Обновить D:\dev\DrillingOptimize и отправить на GitHub
param(
    [string]$ProjectDir = "D:\dev\DrillingOptimize",
    [string]$Remote = "https://github.com/neukuhren/DrillingOptimize.git"
)

$ErrorActionPreference = "Stop"
Set-Location $ProjectDir

if (-not (Test-Path ".git")) {
    git init
}

git remote remove origin 2>$null
git remote add origin $Remote
git add -A
$status = git status --porcelain
if ($status) {
    git commit -m "Sync: Lazarus project updates from dev"
}
git branch -M main
Write-Host "Pushing to $Remote ..."
git push -u origin main
Write-Host "Done. ZIP: https://github.com/neukuhren/DrillingOptimize/archive/refs/heads/main.zip"
