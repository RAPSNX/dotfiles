# Monitor / Workspace setup

`kanshi` is used to match all possible desktop / office setups via profiles.
These profiles configure the primary and secondary display (position, mode, scale) for each known monitor combination.
`nwg-desktop` can still be used for workspace dynamic configuration.

**To actually change the monitor config, the `kanshi` systemd service needs to be stopped.**


## Samsungs auto input switch not working
With `ddcutil` it is possible to switch input of a display port monitor.

```
ddcutil --display 2 setvcp 60 0x09 # Display port (Zion)
ddcutil --display 2 setvcp 60 0x06 # HDMT (Firefly)
```

### TODOs

- Add this to hyprland autostart, to automatically change input on startup.
- Create keybinding to switch both monitors between inputs.
