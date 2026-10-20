# Пост-апдейт: слияние макросов

Источник правды (текущее «хорошее» поведение):
`backups/2026-10-20_SOC-01.01.02.04/config/`

После прошивки сток обычно жёстко паркует голову / режет филамент /
делает лишние `CUT` + `MOVE_TO_TRASH` в конце/паузе. Ниже — что
подхватывать из живого бекапа и куда смотреть.

## Приоритет переноса (по убыванию)

| # | Файл / макрос | Зачем |
|---|---------------|--------|
| 1 | `printer.cfg` → `[gcode_macro E_UNLOAD]` | Кастомный unload: box-slot или `CUT_FILAMENT_1` + `MOVE_TO_TRASH`, без краша на `SLOT=-1/16` |
| 2 | `klipper-macros-qd/gcode_macro.cfg` → `PAUSE` | Мягкий park: z-hop → clear XY → опциональный wipe (`W=`) → trash; idle 12ч/72ч |
| 3 | `…` → `PRINT_END` / `CANCEL_PRINT` | Порядок охлаждения, `G31`, без лишнего резкого cut-цикла |
| 4 | `…` → `MOVE_TO_TRASH` / `CUT_FILAMENT_1` | Координаты trash/cutter (X≈85 / Y≈287.5; cutter Y0.5) |
| 5 | `…` → `CLEAR_NOZZLE*` / `SHAKE_OOZE` | Поведение чистки сопла |
| 6 | `printer.cfg` SAVE_CONFIG | Input shaper + bed_mesh (после апдейта часто сбрасывается) |
| 7 | `saved_variables.cfg` | Слоты box / цвета / флаги (не затирать стоком) |
| 8 | `MCU_ID.cfg` | Serial MCU — обязательно свой |
| 9 | `crowsnest.conf` / `box.cfg` | Камера / box — если менял |

## Типичный конфликт со стоком

Сток (часто):
- резкий park в конец стола без z-hop / без `SAVE_GCODE_STATE`
- `CUT_FILAMENT` на каждом `PRINT_END` / unload
- короткий `idle_timeout` → глохнут моторы среди паузы

Наше live (держать):
- `PAUSE`: retract → Z-hop → park в `clear_x/y` → wipe только при `W!=0`
- `E_UNLOAD`: умный выбор slot / fallback cut+trash
- `PRINT_END`: heaters off → `BED_MESH_CLEAR` → `G31` → status ready (без обязательного cut)

## Процедура после апдейта

1. Снять сток с принтера в `backups/<дата>_после_апдейта_STOCK/`.
2. Diff сток ↔ `2026-10-20_SOC-01.01.02.04` по файлам из таблицы.
3. В стоковый `gcode_macro.cfg` перенести блоки макросов целиком (не «вслепую» весь файл).
4. В стоковый `printer.cfg` вернуть `E_UNLOAD` override + SAVE_CONFIG калибровки.
5. `MCU_ID.cfg` / `saved_variables.cfg` — с живого бекапа.
6. `FIRMWARE_RESTART` → тест: Pause, End print, Unload (с box и без).

## Черновик извлечённых макросов

`notes/custom_macros_extract.cfg` — снимок ключевых блоков из live
для быстрого diff/копипаста.

## Старый эксперимент (не путать с live)

`archive/2026-08-08_SOC-01.01.02.01/current_config/` — патчи от 09.08,
уже не совпадают с принтером. Только как история.
