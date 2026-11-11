# QIDI Q2 — бекапы и прошивка

IP: `192.168.31.75`

## Актуально

`backups/2026-11-11_SOC-01.01.03.02_SOFT/` — снимок с принтера после обновления SOC 01.01.03.02 и soft-патчей.

Предыдущий: `backups/2026-10-20_SOC-01.01.03.01_SOFT_FINAL/`.

## Архив

`archive/` — всё предыдущее (08.08, pre-01.01.02.04, STOCK после апдейта, промежуточный SOFT).

## Прошивка

Источник релизов: https://github.com/kokoc26/qidi-q2-fw/releases

```powershell
cd firmware
.\check-latest.ps1          # последний релиз
.\download-latest.ps1       # скачать ZIP в firmware/downloads/
```

Локально ещё лежит `firmware/QD_Q2_01.01.02.04/` (мелкие `.bin`); тяжёлый SOC/zip в git не входят.

## Soft-патчи в актуальном бекапе

- MOVE_TO_TRASH `F8000` / `F500`
- PRINT_START: рез на старте оставлен, сразу после него `G28`
- после сетки подъезд `F2000`, затем `F500`
- PAUSE / RESUME парковка `F4000`, на паузе idle 12 ч
- idle_timeout 120 с, только `M84` (нагревы не гасит)
- box fan threshold 40 °C
