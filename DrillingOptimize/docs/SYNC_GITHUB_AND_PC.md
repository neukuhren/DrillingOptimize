# Синхронизация: GitHub и локальный ПК

**Актуальная раскладка (согласовано с автором):**

- Локальный проект: **`D:\DrillingOptimize`** (корень репозитория, без вложенной папки).
- Удалённый репозиторий: **https://github.com/neukuhren/DrillingOptimize.git**
- Основная ветка на GitHub: **`master`** (push/pull выполняйте в неё).

Облачный агент не имеет доступа к диску **D:** и к вашему GitHub-аккаунту; push/pull делаете вы на ПК.

---

## Обновить папку с GitHub (pull)

```powershell
cd D:\DrillingOptimize
git pull origin master
```

---

## Сохранить изменения и отправить на GitHub

```powershell
cd D:\DrillingOptimize
git add -A
git status
git commit -m "Описание правок"
git push -u origin master
```

---

## Скачать ZIP без Git

Ветка **master**:

**https://github.com/neukuhren/DrillingOptimize/archive/refs/heads/master.zip**

---

## Скрипты

- `scripts/setup-windows.ps1` — клонирование в **`D:\DrillingOptimize`**.
- `scripts/sync-from-dev.ps1` — commit + push в **master** (по умолчанию каталог **`D:\DrillingOptimize`**).

---

## Последние правки в коде (для справки)

- `GraphPlotUnit.pas` — `uses Math`, корректное выражение `TColor(...)`.
- `MainFormUnit.pas` — переменная `LayoutY` вместо конфликтующего `Top`, прокрутка через `VertScrollBar.Range`.
- `DrillingOptimize.lpi` — `UseMainFormUnit`, `MainUnit` для открытия формы в IDE.
