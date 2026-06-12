# Keyboard: Left Cmd/Option Swapped — Keychron K3 Pro

**Date:** 2026-06-12
**Keyboard:** Keychron K3 Pro (QMK firmware, Bluetooth)
**Ghostty:** 1.3.1

## Symptom

Left Option key sending `left_command` keycode at hardware level. Left Command key sending `left_option`. Effectively swapped. `Cmd+C` typing `ç` instead of copying.

## Root Cause

Keychron K3 Pro QMK firmware persistent layer had Cmd/Option swapped. Likely triggered by accidental key combo (Fn+something for Mac/PC mode toggle) or firmware glitch. The swap lived inside the keyboard firmware — no macOS/Karabiner/hidutil fix could touch it.

## Fix

**Factory reset the keyboard firmware: `Fn + J + Z` held for 4 seconds.**

This clears the QMK persistent layer and restores the default Mac layout. Cmd and Option immediately returned to normal.

## False leads (what didn't work)

- macOS System Settings → Modifier Keys: no effect (keyboard sending wrong keycodes)
- `hidutil property --set UserKeyMapping`: no effect (kernel-level remap can't fix firmware-level swap on this keyboard)
- Karabiner simple_modifications: no effect (wrong format initially, then still didn't work because keyboard was overriding)
- Karabiner complex_modifications: no effect (same reason)

## Notes

- K3 Pro uses QMK with VIA support. To prevent recurrence, check keymap at usevia.app in Chrome
- Physical Mac/PC switch on side was set to Mac — switch itself was fine, firmware was the problem
- Right modifiers were unaffected throughout

## Notes

- Right modifiers unaffected
- If keyboard firmware is ever updated/flashed, remove this workaround and retest
