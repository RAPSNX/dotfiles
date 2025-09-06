{
  lib,
  config,
  ...
}: let
  defaultPlugins = {
    edit-secret = {
      description = "Edit Decoded Secret";
      shortCut = "Ctrl-X";
      scopes = ["secrets"];
      command = "kubectl";
      background = false;
      args = [
        "modify-secret"
        "-n"
        "$NAMESPACE"
        "$NAME"
      ];
    };
  };
  workPlugins = import ./k9s-workplugins.nix;
in {
  catppuccin.k9s.enable = true;
  programs.k9s = {
    enable = true;
    plugins =
      defaultPlugins
      // lib.optionalAttrs config.roles.workdevice workPlugins;
  };
}
