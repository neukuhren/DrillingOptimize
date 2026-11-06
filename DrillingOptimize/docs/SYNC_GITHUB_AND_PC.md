# Синхронизация: GitHub и D:\dev\DrillingOptimize

Облачный агент **не может** записывать на ваш диск **D:** и **не может** выполнить `git push` без вашего входа в GitHub.  
Все правки лежат в этом репозитории (ветка `main`) и в архиве **`releases/DrillingOptimize-2026-11-06.zip`**.

---

## A. Обновить папку на ПК (без Git)

1. Скачайте архив с GitHub (после шага B) или из релиза в папке `releases/`.
2. Распакуйте **поверх** `D:\dev\DrillingOptimize` (заменить файлы).
3. Откройте **`DrillingOptimize.lpi`** (файл в **корне** папки, не во вложенной `DrillingOptimize\DrillingOptimize`).

PowerShell:

```powershell
Expand-Archive -Path "$env:USERPROFILE\Downloads\DrillingOptimize-2026-11-06.zip" -DestinationPath D:\dev\ -Force
# если в zip есть одна папка DrillingOptimize — путь будет D:\dev\DrillingOptimize
```

---

## B. Залить обновления на GitHub (с вашего ПК, один раз)

В каталоге проекта, где уже есть `.git`:

```powershell
cd D:\dev\DrillingOptimize
git remote set-url origin https://github.com/neukuhren/DrillingOptimize.git
git add -A
git status
git commit -m "Lazarus fixes: Math, LayoutY, VertScrollBar, lpi MainUnit"
git branch -M main
git push -u origin main
```

Если репозиторий на GitHub **пустой**, а локально уже есть история — push пройдёт.  
Если GitHub отклонит (несовпадение историй):

```powershell
git pull origin main --allow-unrelated-histories
# разрешить merge при необходимости
git push origin main
```

**TLS / auth:** при ошибке SSL используйте SSH:

```powershell
git remote set-url origin git@github.com:neukuhren/DrillingOptimize.git
git push -u origin main
```

---

## C. Скачать ZIP с GitHub (без Git)

После успешного push:

**https://github.com/neukuhren/DrillingOptimize/archive/refs/heads/main.zip**

---

## D. Скрипт на Windows (обновление + push)

```powershell
powershell -ExecutionPolicy Bypass -File D:\dev\DrillingOptimize\scripts\sync-from-dev.ps1
```

(см. `scripts/sync-from-dev.ps1`)

---

## Последние изменения в коде

- `GraphPlotUnit.pas` — `uses Math`, исправлен `TColor(...)`.
- `MainFormUnit.pas` — переменная `LayoutY` вместо `Top`, `VertScrollBar.Range`.
- `DrillingOptimize.lpi` — `UseMainFormUnit`, `MainUnit` = 1.
