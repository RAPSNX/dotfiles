{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  environment = {
    systemPackages =
      builtins.attrValues {
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
      # TODO: wtf?
      ++ lib.optionals (!config.hostConfig.roles.desktop) (builtins.attrValues {
        inherit (inputs.neonix.packages.${pkgs.stdenv.hostPlatform.system}) mini;
        inherit (pkgs) jq tmux;
      });
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
