# Прошивки QIDI Q2

Источник: community-архив [kokoc26/qidi-q2-fw](https://github.com/kokoc26/qidi-q2-fw)  
ZIP для флеша — в **Releases** (не в git-дереве репы).

Актуальная на принтере (на момент soft-final): **SOC 01.01.03.01**  
→ https://github.com/kokoc26/qidi-q2-fw/releases/tag/V01.01.03.01

## Скрипты

```powershell
# показать последний релиз
.\check-latest.ps1
.\check-latest.ps1 -Json

# скачать latest ZIP в firmware/downloads/
.\download-latest.ps1

# конкретный tag
.\download-latest.ps1 -Tag V01.01.03.01
.\download-latest.ps1 -Force   # перекачать
```

Скачанные ZIP в `downloads/` в git не коммитятся (см. корневой `.gitignore`).

## Локально

Папка `QD_Q2_01.01.02.04/` — старый локальный комплект (мелкие MCU/THR/BOX `.bin` + manifest).  
Тяжёлый SOC/zip в git не входят.
