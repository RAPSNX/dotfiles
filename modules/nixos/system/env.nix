{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      dnsutils # dig, nslookup, etc.
      inetutils # ping, traceroute, etc.

      # Cpu & Networking tools
      htop
      curl

      # TODO: Add neonix mini to all non desktops

      # Programs
      git

      fzf
    ];
    variables = {
      EDITOR = "vim";
      VISUAL = "vim";
    };
  };
}
