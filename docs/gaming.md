# Gaming and Battle.net

`hostConfig.roles.gaming.enable` installs Steam, Lutris, UMU, Gamescope, and
GameMode. Steam owns the Proton 11+ runtime; Home Manager links that runtime to
UMU so it can launch Lutris games without downloading a second copy.

## One-time Steam Runtime setup

Run these commands as `rap` after enabling the gaming role. Steam Runtime 4.0
is Steam tool `4183110` and is required by Proton 11+.

```sh
steam steam://install/4183110
```

Wait for Steam to finish the download, then verify the runtime exists:

```sh
runtime="$HOME/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4"
test -f "$runtime/toolmanifest.vdf" && test -f "$runtime/mtree.txt.gz" \
  && echo "Steam Runtime 4 is ready"
```

Remove any incomplete runtime that UMU created before activating the Home
Manager link:

```sh
rm -rf "$HOME/.local/share/umu/steamrt4"
```

From this repository, apply the system and home configurations:

```sh
nh os switch .
nh home switch .
```

Start a new graphical session, then confirm that UMU resolves to Steam's
runtime:

```sh
readlink -f "$HOME/.local/share/umu/steamrt4"
```

The command should print
`$HOME/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4`.

## Battle.net

Open Lutris, select **+** → **Search the Lutris website for installers**, and
install the standard Battle.net entry into a new Lutris-managed directory such
as `~/Games/battlenet`. Do not run the Battle.net installer manually with
`wine` or set `WINEPREFIX` yourself.

If UMU reports an HTTP 403 while checking for runtime updates, the valid linked
Steam runtime is still used. A `FileNotFoundError` for
`steamrt4/toolmanifest.vdf` means the Steam Runtime bootstrap or Home Manager
link is incomplete.
