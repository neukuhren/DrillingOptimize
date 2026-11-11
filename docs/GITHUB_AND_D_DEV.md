# GitHub и каталог на ПК

Облачный агент **не имеет доступа к вашему диску** и **не может** выполнить `git push` от вашего имени. Клонирование и push делаете на ПК.

**Текущая раскладка:** проект в **`D:\DrillingOptimize`**, репозиторий **https://github.com/neukuhren/DrillingOptimize.git**, ветка по умолчанию **`master`**.

---

## Клонирование

```powershell
git clone https://github.com/neukuhren/DrillingOptimize.git D:\DrillingOptimize
```

Или скрипт: `scripts/setup-windows.ps1` (клон в `D:\DrillingOptimize`).

---

## Обновление и отправка

```powershell
cd D:\DrillingOptimize
git pull origin master
# после правок:
git add -A
git commit -m "Сообщение коммита"
git push -u origin master
```

---

## Загрузка ZIP без Git

**https://github.com/neukuhren/DrillingOptimize/archive/refs/heads/master.zip**

---

## Lazarus

Откройте **`D:\DrillingOptimize\DrillingOptimize.lpi`**.
