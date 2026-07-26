{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.hostConfig.roles.gaming;
in
{
  options.hostConfig.roles.gaming = {
    enable = lib.mkEnableOption "NixOS gaming environment.";

    mouse.enable = lib.mkEnableOption "ratbagd and Piper support for compatible gaming mice.";
  };

  config = lib.mkIf cfg.enable {
    services.ratbagd.enable = cfg.mouse.enable;

    programs = {
      gamemode.enable = true;
      gamescope = {
        enable = true;
        capSysNice = true;
      };
      steam = {
        enable = true;
        extraPackages = builtins.attrValues {
          inherit (pkgs) gamemode mangohud;
        };
        gamescopeSession.enable = true;
        extraCompatPackages = builtins.attrValues {
          inherit (pkgs) proton-ge-bin;
        };
        protontricks.enable = true;
      };
    };

    environment.systemPackages =
      builtins.attrValues {
        inherit (pkgs) lutris umu-launcher;
      }
      ++ lib.optionals cfg.mouse.enable [ pkgs.piper ];
  };
}
