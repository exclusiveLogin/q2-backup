# Отчёт: возврат старых улучшений на SOC 01.01.03.01

**Правило:** новое не трогать.  
**Сравнение:** `backups/2026-10-20_SOC-01.01.02.04` (pre) ↔ `…_01.01.03.01_STOCK` (post)  
**Живой принтер:** klippy ready, SOC 01.01.03.01

---

## Новое (не трогать)

| Компонент | Почему нельзя откатывать |
|-----------|---------------------------|
| `T0`…`T15` → `T_MANAGER T=N` | Новый toolchange API; старый `EXTRUDER_LOAD` из `box.cfg` конфликтует по имени |
| `box.cfg` hardware-only | T-макросы уехали в `gcode_macro.cfg` |
| `[box485]` / `[box2base]` | Новые секции; удаление сломает box-стек |
| `DROP_TRASH`, `WIPE_NOZZLE_DROP`, `TRY_INTO_EXTRUDER`, `MOVE_ANOTHER_POINT_CHANGE_FILAMENT` | Вызываются из UI/native (`box_extras`), в cfg почти нет callers — макросы должны остаться |
| Формат `saved_variables` (цвета как `['898F8B']`, filament как `'QFG00'`) | Новый UI/RFID; откат к int сломает отображение слотов |
| Целиком `gcode_macro.cfg` / `box.cfg` / `printer.cfg` | Сотрёт новое |

---

## Старые улучшения → вердикт по конфликтам

### ✅ Без конфликта с новым (можно возвращать точечно)

| Улучшение | Куда | Риск | Комментарий |
|-----------|------|------|-------------|
| **SAVE_CONFIG** bed_mesh + input_shaper (`zv/44.4`, `mzv/43.4`, mesh kamp/default) | хвост `printer.cfg` | низкий | Аддитивно; сток оставил только shaper `3hump_ei/68.8`, mesh стёрт |
| **`MOVE_TO_TRASH` скорости** `F8000/500` вместо `F20000/1500` | тело макроса | низкий | Имена те же; `DROP_TRASH`/`WIPE_*` вызывают его → станут мягче (плюс) |
| **`PAUSE` park F4000** + `SET_IDLE_TIMEOUT TIMEOUT=43200` в начале | тело `PAUSE` | низкий | Не пересекается с T*/DROP*; wipe-блок уже одинаковый |
| **`CLEAR_NOZZLE` более низкие F** | тело макроса | низкий | Только скорости wipe |
| **`PRINT_START`:** убрать `CUT_FILAMENT_1` + второй `G28`, вернуть soft `MOVE_TO_TRASH` → Z5 → Y280 | тело `PRINT_START` | низкий* | Новые макросы DROP/WIPE не удаляются; меняется только старт печати. *Поведение стока станет мягче — это и есть цель |
| **`idle_timeout: 120`** + `M84` (как было) | `[idle_timeout]` | низкий | Не связано с box API |
| **`square_corner_velocity: 5`**, `z_tilt` hmove_z/speed как pre | `printer.cfg` | низкий | Тюнинг, не API |
| **runout:** вернуть `and printer["box_extras"]` | filament sensor | низкий | Более безопасный guard |

`PRINT_END` / `CANCEL_PRINT` / `CUT_FILAMENT_1` — **уже совпадают**, возвращать нечего.

---

### ⛔ Конфликт / нельзя возвращать as-is

#### 1. Кастомный `[gcode_macro E_UNLOAD]` — **высокий риск**

Pre-патч:
```ini
[gcode_macro E_UNLOAD]
rename_existing: BASE_E_UNLOAD
… EXTRUDER_UNLOAD SLOT=…
… else: CUT_FILAMENT_1 + MOVE_TO_TRASH …
```

На живом 01.01.03.01:
- в `configfile` / objects **нет** `E_UNLOAD`, `BASE_E_UNLOAD`, `EXTRUDER_UNLOAD`
- в help есть **`UNLOAD_FILAMENT`**, `UNLOAD_FILAMENT_CONTROL`
- `M603` по-прежнему вызывает `E_UNLOAD SLOT=16` при box

Следствия:
1. `rename_existing: BASE_E_UNLOAD` → **вероятный fail загрузки конфига** (нечего переименовывать).
2. Даже если обернуть вручную: `SLOT=16` у pre **не** в диапазоне 0–15 → уйдёт в cut+trash и **сломает** штатный box-unload из `M603`.
3. Вызовы `EXTRUDER_UNLOAD` — **устаревший API** (заменён на `UNLOAD_FILAMENT*`).

**Вердикт:** старый `E_UNLOAD` **не возвращать**.  
Если чинить unload — писать новый тонкий wrapper под API 01.01.03.01 (отдельная задача), не копипаст pre.

#### 2. Старые `T0`…`T15` / `UNLOAD_T*` из pre-`box.cfg` — **прямой конфликт имён**

Post: `T0` = `T_MANAGER T=0`.  
Вставка старых T* → перетрёт новый toolchange.

**Вердикт:** не возвращать.

#### 3. Целиком pre-`saved_variables.cfg` — **конфликт формата**

Цвета/filament сменили тип (int → list/string).

**Вердикт:** не заливать файл целиком; калибровки mesh/shaper живут в `printer.cfg` SAVE_CONFIG.

#### 4. Целиком pre-`gcode_macro.cfg` — **сотрёт новое**

Убьёт T*, DROP_TRASH, WIPE_*, TRY_INTO_EXTRUDER и др.

**Вердикт:** только точечный diff по разрешённым макросам.

---

## Матрица «что делать»

| # | Действие | Конфликт с новым? |
|---|----------|-------------------|
| 1 | Влить SAVE_CONFIG (mesh+shaper) из pre | нет |
| 2 | Смягчить `MOVE_TO_TRASH` скорости | нет (даже помогает DROP/WIPE) |
| 3 | Смягчить `PAUSE` (F4000 + idle 12ч в начале) | нет |
| 4 | Смягчить хвост `PRINT_START` (без лишнего CUT+G28) | нет* (новые макросы целы) |
| 5 | Опционально: idle_timeout / SCV / CLEAR_NOZZLE speeds | нет |
| 6 | Вернуть pre-`E_UNLOAD` | **ДА — нельзя** |
| 7 | Вернуть pre-T* / pre-box.cfg целиком | **ДА — нельзя** |
| 8 | Залить pre-`gcode_macro.cfg` целиком | **ДА — нельзя** |

---

## Рекомендуемый порядок безопасного merge

1. Бэкап текущего стока (уже есть `…_01.01.03.01_STOCK`).
2. Патч **только** разрешённых блоков (1–5), не файлы целиком.
3. `FIRMWARE_RESTART`.
4. Тесты: Pause → Resume; End print; Unload с box (`M603`); toolchange T0/T1; старт печати (нет резкого cut на старте).
5. `E_UNLOAD` — отдельно спроектировать под `UNLOAD_FILAMENT*`, если unload с box реально падает.

---

## Замечание по стоку

`M603` вызывает `E_UNLOAD SLOT=16`, но макроса `E_UNLOAD` в конфиге/objects нет.  
Возможно, команда из native-модуля не светится в help — либо это дыра 01.01.03.01.  
Перед любым wrapper — проверить на UI: Unload filament с подключённым box. Если падает `Unknown command: E_UNLOAD` — чинить новым макросом-адаптером, не pre-копией.
