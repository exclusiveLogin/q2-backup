# Post-update snapshot — STOCK after flash to SOC 01.01.03.01
Compared against: backups/2026-10-20_SOC-01.01.02.04 (pre-update live)

Versions: SOC 01.01.03.01 | MCU 02.01.01.09 | THR 02.02.01.08 | BOX KLP_MCU_MKS_V2_1.1.3
klippy: ready

Changed files: printer.cfg, gcode_macro.cfg, box.cfg, saved_variables.cfg
Unchanged: MCU_ID, crowsnest, moonraker, KAMP/*, timelapse, fluidd, drying, filas_list

Critical losses vs pre:
- E_UNLOAD override removed from printer.cfg
- SAVE_CONFIG bed_mesh wiped; input_shaper reset to 3hump_ei/68.8 + mzv/42.2
- PRINT_START now calls CUT_FILAMENT_1 + fast park moves
- MOVE_TO_TRASH speeds F8000/500 -> F20000/1500
- box T0-T15 macros moved from box.cfg into gcode_macro.cfg; box.cfg hardware-only
