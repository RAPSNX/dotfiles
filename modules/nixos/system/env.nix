{
  pkgs,
  config,
  inputs,
  ...
}:
{
  environment = {
    systemPackages =
      with pkgs;
      [
        dnsutils # dig, nslookup, etc.
        inetutils # ping, traceroute, etc.

        # Cpu & Networking tools
        htop
        curl

        # Tooling
        git
        curl
        fzf
        file

        jq
        yq-go
        gawk
        gnused

        p7zip
        gnumake
      ]
      # TODO: wtf?
      ++ lib.optionals (!config.hostConfig.roles.desktop) [
        inputs.neonix.packages.${pkgs.stdenv.hostPlatform.system}.mini
        jq
        tmux
      ];
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
