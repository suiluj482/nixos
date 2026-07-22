# Quickshell Desktop Config

A [Quickshell](https://github.com/Quickshell/Quickshell)-based desktop shell config for the [Niri](https://github.com/YaLTeR/niri) Wayland compositor, themed with Catppuccin Mocha.

## Panels

- **Bar** — 30px top bar with workspace dots, window icons, clock, active window title, system tray, volume, brightness, battery, sleep inhibitor, and Home Assistant controls.
- **BarLeft / BarRight / BarBottom** — Thin invisible edge strips (6px/8px) for click and scroll navigation.

## Overlays

- **PowerMenu** — Full-screen overlay with action tiles: shutdown, reboot, suspend, lock, logout, UEFI firmware, Windows reboot, and NixOS rebuild. Keyboard-navigable with hotkeys.
- **OSD** — Auto-hiding volume on-screen display, triggered on volume/mute changes.

## Widgets

| Widget | Description |
|---|---|
| WorkspacesWidget | Dots for each workspace; click to switch, scroll to navigate |
| WindowsWidget | App icons for windows on the current workspace |
| ActiveWindowWidget | Focused window title with maximize and close buttons |
| ClockWidget | Date/time display (`ddd, MMM dd - HH:mm`) |
| VolumeWidget | PipeWire volume icon, percentage, mute toggle |
| BrightnessWidget | Brightness control via `ddcutil` (desktop) or `brightnessctl` (laptop) |
| PowerWidget | Battery status + power profile selector (laptop only) |
| PowerButtonWidget | Power icon toggle that opens the PowerMenu |
| SystemTrayWidget | Expandable system tray with context menu support |
| InhibitWidget | Sleep inhibitor toggle with active inhibitor list |
| HAWidget | Home Assistant CO2 readout and light controls |

## Services

- **NiriService** — IPC with Niri over its Unix socket; exposes workspaces, windows, and focus state.
- **PipewireState** — Reactive PipeWire default audio sink wrapper.
- **HAService** — Home Assistant client over a Unix socket; caches entities and provides callService/turnOn/turnOff/toggle/setBrightness.
- **PowerMenuState** — Singleton toggle for the PowerMenu overlay.

## Theme

**Catppuccin Mocha** with `mauve` (#cba6f7) accent. Fonts: JetBrains Mono (body), Inter (labels/headers).

## Configuration

The `DEVICE_TYPE` environment variable (`desktop` or `laptop`) controls:
- Whether the battery/power widget is shown
- Which brightness backend is used

## Dependencies

- **Runtime:** Quickshell ≥0.3.0, Qt 6, Niri, PipeWire, systemd
- **Peripherals:** `brightnessctl` (laptop), `ddcutil` (desktop), `UPower`
- **External:** Home Assistant running `ha-linux.sock`, `hyprlock`, `kitty`, Nerd Font, JetBrains Mono, Inter
