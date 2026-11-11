# Клонирование репозитория в D:\DrillingOptimize (Windows, PowerShell)
# Запуск:  powershell -ExecutionPolicy Bypass -File setup-windows.ps1

param(
    [string]$RepoUrl = "https://github.com/neukuhren/DrillingOptimize.git",
    [string]$TargetRoot = "D:\"
)

$ErrorActionPreference = "Stop"

$ProjectDir = Join-Path $TargetRoot "DrillingOptimize"

if (-not (Test-Path -LiteralPath $TargetRoot)) {
    New-Item -ItemType Directory -Path $TargetRoot | Out-Null
    Write-Host "Создан каталог $TargetRoot"
}

if (Test-Path -LiteralPath $ProjectDir) {
    Write-Host "Каталог уже существует: $ProjectDir"
    Write-Host "Обновление: git pull origin master"
    Set-Location $ProjectDir
    git pull origin master
} else {
    Set-Location $TargetRoot
    git clone $RepoUrl DrillingOptimize
    Write-Host "Клонировано в $ProjectDir"
}

Write-Host ""
Write-Host "Откройте в Lazarus: $ProjectDir\DrillingOptimize.lpi"
