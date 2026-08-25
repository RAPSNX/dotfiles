{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  options.hostConfig.environment.enableNeonixMini = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Install the Neonix mini package bundle on non-desktop hosts.";
  };

  config = {
    environment = {
      systemPackages =
        lib.attrValues {
          inherit (pkgs)
            curl
            dnsutils
            file
            fzf
            gawk
            git
            gnumake
            gnused
            htop
            inetutils
            jq
            p7zip
            yq-go
            ;
        }
        ++
          lib.optionals (!config.hostConfig.roles.desktop && config.hostConfig.environment.enableNeonixMini)
            (
              lib.attrValues {
                inherit (inputs.neonix.packages.${pkgs.stdenv.hostPlatform.system}) mini;
                inherit (pkgs) jq;
              }
            );
      variables = {
        EDITOR = "vim";
        VISUAL = "vim";
      };
    };
  };
}
