# Install device
1. Install it via usb-image
2. Install lix
3. Create local user
4. Get user-certificate with chandler
3. clone dotfiles
4. Make home-manager switch

```
home-manager switch --flake .#rapsn@firefly
```

## Manual things

### Disable gpg-agent
```
systemctl --user mask --now gpg-agent.service gpg-agent.socket \
  gpg-agent-ssh.socket gpg-agent-extra.socket gpg-agent-browser.socket
```

### Copy user-certificate to firefox

```bash
cp .pki/nssdb/* /home/rapsn/.mozilla/firefox/default/
```

### GTK Theme

Instead of configuring every theme myself, only the theme installation is managed via `nix`, to set the theme use `nwg-look`.

## Outside nix 😭
- mumble (apt)
- hyprland (apt ppa:piper)
