# TODO(docs): add workdevice
- firefox used from snaps, managed via sync
- chromium used for google apps -> extension open in firefox configured (reverse, and google.com as domain)
- ubuntu has diffrent umask -> diff on make generate


- wlr portal is installed via apt

- lix is installed via upstream


# Install device
1. Install it via usb-image
2. Install lix
3. clone repo to /mnt/dotfiles
4. Make home-manager switch

```
home-manager switch --flake .#raphael.groemmer@stackit.cloud@firefly
```

## Manual things

### Disable gpg at all
```
systemctl --user mask gpg-agent.service
systemctl --user mask gpg-agent.socket
systemctl --user mask gpg-agent-ssh.socket
systemctl --user mask gpg-agent-extra.socket
systemctl --user mask gpg-agent-browser.socket
systemctl --user stop gpg-agent.service
```
