{ pkgs, ... }:
let
  dot = pkgs.writeShellScriptBin "dot" ''
    # Cleanup
    rm -rf dotfiles
    set -euo pipefail

    gum style --foreground 82 --align left 'Wake up, Neo ... 💻'

    # Cloneing
    gum spin --show-error -s line --title "Cloning the Nixify repository..." -- \
      git clone https://github.com/rgroemmer/dotfiles && cd dotfiles

    gum style --foreground 40 --align left 'The Matrix has you ...'

    # Branch selection (for development)
    BRANCH=$(git branch -r | grep -v "\->" | awk -F'/' '{print $2}' | gum choose)
    git checkout $BRANCH

    gum style --foreground 118 --italic --align left 'Follow the white rabbit. 🐰'

    # Choose
    ALL_CONFIGS=$(nix flake show 2>/dev/null --json | jq -r '.nixosConfigurations | keys[]' | grep -v vinox)
    HOST=$(gum choose $ALL_CONFIGS)
    DISKO_CONFIG="./hosts/$HOST/disko.nix"

    # Installation
    # Disko
    gum spin --show-error -s line --title "Preparing disks for $HOST" -- \
      nix run github:nix-community/disko --no-write-lock-file -- --mode zap_create_mount "$DISKO_CONFIG"

    # NixOS
    gum spin --show-error -s line --title "Installing NixOS configuration for $HOST" -- \
      nixos-install --flake .#$HOST

    gum style --foreground 124 --bold --align left 'Knock, knock, Neo.' && sleep 1
    reboot
  '';
in
{
  environment.systemPackages = with pkgs; [
    dot # My interactive installer
    gum
    alacritty
  ];
}
