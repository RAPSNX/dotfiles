# Noctalia

Noctalia is the desktop shell for Hyprland.
Hyprland remains the compositor and window-management layer, Noctalia provides the panel, application and emoji launcher, notifications, session actions, wallpapers, clipboard history, tray, OSD, and control centre.

## Migrated components

| Previous component | Noctalia replacement |
|---|---|
| Waybar | Top bar: launcher, workspaces, submap indicator (plugin), clock, tray, system monitors and quick controls |
| Fuzzel and Rofi Emoji | Launcher with application, calculator, emoji, wallpaper and window providers |
| SwayNC | Notification daemon and notification history |
| Wlogout | Session panel with native lock, hibernate, logout, suspend, shutdown and reboot actions |
| Hyprpaper | Native wallpaper service |
| Hyprlock | Native Noctalia screen locking; Firefly delegates to its system `swaylock` |
| NetworkManager and Blueman tray applets | Noctalia control-centre widgets and tray |
| Pavucontrol | Noctalia audio controls |
| Grimblast package | Noctalia screenshot service |

Noctalia additionally enables clipboard history, screen time, per-output wallpaper selection, a system monitor, calendar, scheduled night light, brightness OSD, a Windows-reboot session action on Zion, and a dynamic `hypr-submap` bar plugin widget to visually display active Hyprland modes (`resize`, `windows`, `noctalia`).

## Wallpapers

Noctalia manages wallpapers directly. The declarative configuration supplies `minimal-space.jpg` as the global fallback; use Noctalia's wallpaper picker to assign images to individual outputs. Those per-output selections are stored in Noctalia's state directory and persist across rebuilds.

## Shell shortcuts

| Key | Action |
|---|---|
| `Super+E` | Toggle launcher |
| `Super+P` | Toggle session panel |
| `Super+N` | Enter Noctalia mode (`n` notifications, `m` monitor, `c` calendar, `s` region capture, `S` full capture, `a` annotate with satty) |
| `Super+.` | Open emoji search |
| `Alt+Tab` | Open window switcher |
