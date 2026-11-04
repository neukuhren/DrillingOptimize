# GitHub и каталог D:\dev\

Облачный агент **не имеет доступа к диску D:** на вашем ПК и **не может** создать репозиторий GitHub без вашей авторизации. Ниже — два коротких сценария.

---

## A. Создать репозиторий на GitHub (вручную, ~2 мин)

1. Откройте [https://github.com/new](https://github.com/new).
2. **Repository name:** `DrillingOptimize` (или своё имя).
3. **Public** или **Private** — на ваш выбор.
4. **Не** добавляйте README / .gitignore (проект уже готов).
5. Нажмите **Create repository**.

Скопируйте URL, например: `https://github.com/<ваш-логин>/DrillingOptimize.git`

---

## B. Залить код с агента (если есть clone/push с машины, где лежит архив)

Если вы скачали проект из агента:

```powershell
cd D:\dev
mkdir DrillingOptimize 2>$null
cd DrillingOptimize
git init
git remote add origin https://github.com/<логин>/DrillingOptimize.git
git add .
git commit -m "Initial commit: Lazarus drilling optimization"
git branch -M main
git push -u origin main
```

---

## C. Каталог D:\dev\ через скрипт (после push на GitHub)

1. Отредактируйте `scripts/setup-windows.ps1`: укажите свой `$RepoUrl`.
2. В PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File D:\dev\DrillingOptimize\scripts\setup-windows.ps1
```

Или одной строкой (подставьте URL):

```powershell
New-Item -ItemType Directory -Force -Path D:\dev | Out-Null
git clone https://github.com/<логин>/DrillingOptimize.git D:\dev\DrillingOptimize
```

3. Lazarus: **File → Open** → `D:\dev\DrillingOptimize\DrillingOptimize.lpi`

---

## D. Авторизация GitHub CLI (опционально)

На ПК:

```powershell
gh auth login
gh repo create DrillingOptimize --public --source=. --remote=origin --push
```

(из каталога с проектом, после `git init` и первого commit)

---

## Авторизация агента для push от вашего имени

Если нужно, чтобы **агент сам** создал repo и сделал push, в чате один раз выполните на ПК:

```powershell
gh auth login
```

и пришлите ссылку на **пустой** созданный реpositoriy — или создайте **Fine-grained PAT** с правами **Contents: Read and write** и сообщите, что repo создан (токены в чат лучше не вставлять; безопаснее — только `gh auth login` локально и push по инструкции выше).
