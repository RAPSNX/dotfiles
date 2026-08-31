# Hyprland

## Lua configuration

Home Manager generates `~/.config/hypr/hyprland.lua` from the shared Hyprland module. Edit the Nix module instead of the generated Lua file, then rebuild the relevant Home Manager profile. To validate the rendered configuration before activation, run `Hyprland --verify-config -c <generated-hyprland.lua>`.

General docs for hyprland.

## Keymap
<table width="100%">
<tr>
<td valign="top" width="50%">

## Common

| Key | Action |
|---|---|
| `Super+Enter` | Terminal |
| `Super+E` | Launcher |
| `Super+P` | Noctalia session panel |
| `Super+Q` | Kill active |
| `Alt+Shift` | Switch keyboard layout |
| `Alt+Tab` | Window switcher |
| `Super+N` | Enter Noctalia mode |
| `Super+.` | Noctalia emoji search |

## Window

| Key | Action |
|---|---|
| `Super+F` | Fullscreen |
| `Super+Shift+F` | Full-Fullscreen |
| `Super+U` | Toggle floating |
| `Super+T` | Toggle split |
| `Super+Mouse1` | Move |
| `Super+Mouse2` | Resize |

## Focus / Move

| Key | Action |
|---|---|
| `Super+H/J/K/L` | Focus window L/D/U/R |
| `Super+Shift+H/J/K/L` | Move window L/D/U/R |

## Workspaces

| Key | Action |
|---|---|
| `Super+1…9` | Go `1…9` |
| `Alt+1…8` | Move `1…8` |

</td>
<td valign="top" width="50%">

## Special Workspaces

| Key | Action |
|---|---|
| `Super+O` | Toggle `scratchy` |
| `Super+M` | Toggle `aux` |
| `Super+Shift+O` | Move active to `scratchy` |
| `Super+Shift+M` | Move active to `aux` |

## Programs

| Key | Action |
|---|---|
| `Super+Z` | Mumble mute |
| `Super+Shift+Z` | Mumble deaf |
| `Super+.` | Noctalia emoji search |

## Noctalia Mode

Enter: `Super+N`

| Key | Action |
|---|---|
| `N` | Notifications / Control Center |
| `M` | System monitor |
| `C` | Calendar |
| `S` | Screenshot region (Noctalia) |
| `Shift+S` | Screenshot fullscreen (Noctalia) |
| `A` | Annotated screenshot (Satty) |
| `Enter` / `Esc` | Exit |

## Resize Mode

Enter: `Super+R`

| Key | Action |
|---|---|
| `H/J/K/L` | Resize |
| `Shift+H/J/K/L` | Small resize |
| `Enter` / `Esc` | Exit |

## Window Mode

Enter: `Super+G`

| Key | Action |
|---|---|
| `Q/W/E/R` | Move window to workspace |
| `B` | Get firefox |
| `Shift+B` | Send firefox back to `3` |
| `Enter` / `Esc` | Exit |

</td>
</tr>
</table>
