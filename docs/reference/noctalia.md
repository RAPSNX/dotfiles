# Noctalia

Noctalia is the desktop shell for the Hyprland profiles. Hyprland remains the compositor and window-management layer; Noctalia provides the panel, application and emoji launcher, notifications, session actions, wallpapers, lock screen, idle manager, clipboard history, tray, OSD, and control centre.

The dock is deliberately disabled.

## Configuration model

`modules/home/desktops/noctalia/default.nix` is the declarative baseline. Noctalia's Settings UI may store user-level overrides in its state directory; these survive rebuilds. The shipped baseline is reapplied only when the Home Manager configuration changes.

Zion also enables Noctalia Greeter through Greetd. Firefly uses the shell role only because it is configured as a Home Manager-only profile.

## Migrated components

| Previous component | Noctalia replacement |
|---|---|
| Waybar | Top bar: launcher, workspaces, clock, tray, system monitors and quick controls |
| Fuzzel and Rofi Emoji | Launcher with application, calculator, emoji, wallpaper and window providers |
| SwayNC | Notification daemon and notification history |
| Wlogout | Session panel with lock, hibernate, logout, suspend, shutdown and reboot actions |
| Hyprpaper | Native wallpaper service |
| Hyprlock | Native lock screen |
| Hypridle | Native idle manager |
| NetworkManager and Blueman tray applets | Noctalia control-centre widgets and tray |
| Pavucontrol | Noctalia audio controls |
| Grimblast package | Noctalia screenshot service |

Noctalia additionally enables clipboard history, screen time, per-output wallpapers, a system monitor, calendar, scheduled night light, brightness OSD, and a Windows-reboot session action on Zion.

## Wallpaper migration

A one-time user service transfers the legacy Hyprpaper assignments after Noctalia starts. It records completion in `$XDG_STATE_HOME/noctalia/.wallpapers-migrated-v1`, so subsequent rebuilds preserve changes made through Noctalia.

| Previous output selector | Wallpaper |
|---|---|
| `eDP-1` | `anime-city.jpg` |
| `DP-1` | `gohan-supersaiyan.png` |
| Dell `AW2725Q G2QC174` | `luffy-gear-5.jpg` |
| Samsung `LC27G7xT H4ZNC00167` | `one-piece-logo.jpg` |
| fallback | `minimal-space.jpg` |

Remove that marker only when the declarative migration should be run again.

## Shell shortcuts

| Key | Action |
|---|---|
| `Super+E` | Toggle launcher |
| `Super+P` | Toggle session panel |
| `Super+N` | Open notification controls |
| `Alt+V` / `AltGr+V` | Toggle clipboard history |
| `AltGr+C` | Toggle calendar |
| `AltGr+S` | Toggle system monitor |
| `Super+.` | Open emoji search |
| `Alt+Tab` | Open window switcher |
