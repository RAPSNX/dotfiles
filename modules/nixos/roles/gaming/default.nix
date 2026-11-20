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

    # Keep the manually provisioned UMU runtime; update it explicitly when
    # changing runners. This does not link it to Steam's separate runtime.
    environment.sessionVariables.UMU_RUNTIME_UPDATE = "0";

    programs = {
      gamemode.enable = true;
      gamescope = {
        enable = true;
        enableWsi = true;
        capSysNice = true;
      };
      steam = {
        enable = true;
        extraPackages = builtins.attrValues {
          inherit (pkgs) gamemode mangohud;
        };
        gamescopeSession = {
          enable = true;

          # Opt into HDR reporting for older DXVK/Proton versions, only inside
          # the HDR-capable session. Games still choose their own SDR/HDR mode.
          env.DXVK_HDR = "1";

          args = [
            "--backend"
            "drm"
            # Alienware AW2725Q; DP-2 is the secondary Samsung monitor.
            "--prefer-output"
            "DP-1"
            "--hdr-enabled"
            "--adaptive-sync"
            "-W"
            "3840"
            "-H"
            "2160"
            "-r"
            "240"
          ];
        };
        extraCompatPackages = builtins.attrValues {
          inherit (pkgs) proton-ge-bin;
        };
        protontricks.enable = true;
      };
    };

    environment.systemPackages = [
      # Lutris already has per-game Gamescope/HDR controls. Make their tools
      # available inside its FHS runtime as well as on the host.
      (pkgs.lutris.override {
        # The FHS profile puts /run/wrappers first. Its capability-enabled
        # Gamescope cannot inherit capabilities inside the container.
        lutris-unwrapped = pkgs.lutris-unwrapped.overrideAttrs (old: {
          makeWrapperArgs = (old.makeWrapperArgs or [ ]) ++ [
            "--prefix"
            "PATH"
            ":"
            (lib.makeBinPath [ pkgs.gamescope ])
          ];
        });
        extraPkgs =
          runtimePkgs:
          builtins.attrValues {
            inherit (runtimePkgs)
              gamescope
              gamemode
              mangohud
              umu-launcher
              ;
          };
      })
    ]
    ++ builtins.attrValues {
      inherit (pkgs) umu-launcher;
    }
    ++ lib.optionals cfg.mouse.enable [ pkgs.piper ];
  };
}
