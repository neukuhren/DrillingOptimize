# Обновить локальный проект и отправить на GitHub (ветка master)
param(
    [string]$ProjectDir = "D:\DrillingOptimize",
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
    git commit -m "Sync: Lazarus project updates"
}
Write-Host "Pushing to $Remote (branch master) ..."
git push -u origin master
Write-Host "Done. ZIP: https://github.com/neukuhren/DrillingOptimize/archive/refs/heads/master.zip"
