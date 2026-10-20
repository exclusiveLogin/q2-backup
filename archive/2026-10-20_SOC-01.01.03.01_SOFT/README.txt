# SOFT patch on SOC 01.01.03.01 STOCK

Не тронуто: CLEAR_NOZZLE / DROP_TRASH / WIPE / SHAKE wipe-танцы, T0-T15, box485, SAVE_CONFIG.

Изменено:
1. MOVE_TO_TRASH: F20000/1500 -> F8000/500
2. PRINT_START: убран CUT_FILAMENT_1 + жёсткий G28/F30000; мягкий prep
3. PAUSE: idle 43200 в начале, park F4000, hold 72H как сток
4. RESUME_PRINT: возврат к clear F4000 (wipe сток)
5. idle_timeout: 120 + M84 (моторы гаснут в простое)
6. PRINT_END: M84 уже был

SAVE_CONFIG: не трогали — первая калибровка напечатает новую сетку.
