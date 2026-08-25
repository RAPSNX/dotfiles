{
  pkgs,
  inputs,
  lib,
  ...
}:
{
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
      ++ lib.attrValues {
        inherit (inputs.neonix.packages.${pkgs.stdenv.hostPlatform.system}) mini;
      };
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
