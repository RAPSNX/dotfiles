{config, ...}: {
  sops.secrets.atuin = {
    sopsFile = ../../../common/secrets.yaml;
    path = "${config.xdg.configHome}/atuin/config.toml";
    mode = "750";
  };
  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow"
    ];
  };
}
