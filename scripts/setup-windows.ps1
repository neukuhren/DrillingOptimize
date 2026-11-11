# Клонирование проекта в D:\dev\ (Windows, PowerShell)
# Запуск:  powershell -ExecutionPolicy Bypass -File setup-windows.ps1
# Перед запуском замените $RepoUrl на URL вашего репозитория GitHub.

param(
    [string]$RepoUrl = "https://github.com/USER/DrillingOptimize.git",
    [string]$TargetRoot = "D:\dev"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $TargetRoot)) {
    New-Item -ItemType Directory -Path $TargetRoot | Out-Null
    Write-Host "Создан каталог $TargetRoot"
}

$ProjectDir = Join-Path $TargetRoot "DrillingOptimize"

if (Test-Path -LiteralPath $ProjectDir) {
    Write-Host "Каталог уже существует: $ProjectDir"
    Write-Host "Обновление: git -C `"$ProjectDir`" pull"
    Set-Location $ProjectDir
    git pull
} else {
    Set-Location $TargetRoot
    git clone $RepoUrl DrillingOptimize
    Write-Host "Клонировано в $ProjectDir"
}

Write-Host ""
Write-Host "Откройте в Lazarus: $ProjectDir\DrillingOptimize.lpi"
