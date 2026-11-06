# Changelog

## 2026-11-06

- Docs: локальный путь **`D:\DrillingOptimize`**, ветка GitHub **`master`**; обновлены `README`, `SYNC_GITHUB_AND_PC`, скрипты `setup-windows` / `sync-from-dev`.
- Fix compile: `GraphPlotUnit` — add `Math` for `ArcTan2`; fix extra parenthesis in `TColor(...)`.
- Fix compile: `MainFormUnit` — rename local `Top` to `LayoutY` (conflict with `Controls.Top`).
- Fix compile: use `ScrollBoxParams.VertScrollBar.Range` instead of non-existent `VertScrollRange`.
- Move `AddLabeledEdit` into form class; dynamic layout for second group box.
- `DrillingOptimize.lpi`: `UseMainFormUnit` / `MainUnit` for IDE form opening.
- Docs: `SYNC_GITHUB_AND_PC.md`, `sync-from-dev.ps1`, release zip in `releases/`.
