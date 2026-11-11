# Актуальный бекап QIDI Q2 — SOC 01.01.03.02 SOFT

Снято с принтера 192.168.31.75 после обновления 01.01.03.02 и soft-патчей.

Содержит:
- MOVE_TO_TRASH F8000 / F500
- PRINT_START: рез CUT_FILAMENT_1 оставлен, после него G28 и Z_TILT
- после сетки подъезд F2000, затем F500
- PAUSE / RESUME парковка F4000, на паузе idle 43200 с
- idle_timeout 120 с, только M84
- box fan heater_temp 40

Не трогали: новый g28 / lazy_home из 03.02, токи моторов, T0–T15, SAVE_CONFIG.
