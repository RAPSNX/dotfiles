{ pkgs, ... }:
{
  home.packages = builtins.attrValues {
    inherit (pkgs) gcr_4 seahorse;
  };
}
