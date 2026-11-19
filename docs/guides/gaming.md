# Gaming, HDR and Battle.net

Enable `hostConfig.roles.gaming.enable` for Steam, Lutris, UMU, Gamescope and GameMode.

## Runtime setup

Install Steam Runtime 4 for Proton 11+:

```sh
steam steam://install/4183110
```

UMU uses its own runtime at `~/.local/share/umu/steamrt4`. If
`toolmanifest.vdf` is missing, launch the game once with `UMU_RUNTIME_UPDATE=1`,
then remove the override. Keep an existing runtime; do not replace it with a symlink.

## HDR

Use the Alienware display (`DP-1`, 3840×2160 at 240 Hz) and enable HDR in-game.

- **Steam session:** quit Steam, select **Steam** at login, choose
  **GE-Proton11-12** in the game's Compatibility settings, and leave launch options empty.
- **Steam on Hyprland:** for compatible GE-Proton games, use:

  ```sh
  PROTON_ENABLE_WAYLAND=1 PROTON_FORCE_HDR=1 %command%
  ```

- **Lutris:** under **Configure → System options**, enable **Gamescope** and
  **Enable HDR (Experimental)** per game. Select fullscreen, `3840x2160`, `240` Hz
  and `--backend wayland`. Use GE-Proton via UMU with X11/XWayland;
  do not also enable native Wayland/Proton HDR.

Keep desktop-only launch options out of the Steam session. Leave HDR options
unset for SDR games. In Lutris, use its MangoHud toggle instead of adding a wrapper.

## Battle.net

In Lutris, use **+ → Search the Lutris website for installers → Battle.net**.
Install into a new directory such as `~/Games/battlenet`; do not run the installer
manually with Wine or set `WINEPREFIX` yourself.

## Troubleshooting

- **UMU HTTP 403:** an existing complete runtime can still work; check the runtime above.
- **No HDR:** check the monitor OSD and the game's HDR setting. Enshrouded's
  `enshrouded.log` must report HDR enabled/supported and an HDR swapchain;
  surface support alone is insufficient. The previous audit did not verify live HDR.
- **4K/240 Hz fails:** test 120 Hz first. After leaving an HDR game in Hyprland,
  check that the desktop returns to normal SDR colors.
