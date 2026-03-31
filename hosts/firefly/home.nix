{
  lib,
  config,
  pkgs,
  ...
}:
{

  home = {
    username = "raphaelgroemmer";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "22.05";
  };

  roles = {
    work = true;
    email = "raphael.groemmer@digits.schwarz";

    apparmor-gen = with pkgs; [
      config.programs.chromium.finalPackage
      obsidian
    ];

    desktop = {
      monitors = {
        main = "Dell Inc. AW2725Q G2QC174";
        left = "Samsung Electric Company LC27G7xT H4ZNC00167";
      };

      hyprland = {
        enable = true;
        package = pkgs.hyprland;

        hyprlock.enable = true;
        hypridle = {
          enable = true;
          cmd = "${config.home.homeDirectory}/Projects/swaywm/swaylock/build/swaylock";
        };
      };
    };

    cli = {
      zsh.zshrc = ''
        [ -n "$GCTL_SESSION_ID" ] || [ -n "$TERM_SESSION_ID" ] || export GCTL_SESSION_ID=$(uuidgen)
        source <(gardenctl completion zsh)
        eval $(gardenctl kubectl-env zsh)
      '';
    };
  };

  home.packages = with pkgs; [
    # CLIs
    mypkgs.gardenctl
    mypkgs.gardenlogin
    stackit-cli
    openstackclient-full
    vault-bin

    # Tools(inputs.import-tree.match ".*/default\\.nix" ./modules/home)
    brightnessctl
  ];

  targets.genericLinux = {
    enable = true;
    gpu.enable = true;
  };
}
