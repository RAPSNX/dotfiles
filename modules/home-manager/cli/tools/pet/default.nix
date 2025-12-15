{
  lib,
  inputs,
  ...
}: {
  programs.pet = {
    enable = true;
    settings = {
      General = lib.mkForce {
        snippetfile = "${inputs.self.outPath}/extra/snippet.toml";
        selectcmd = "fzf --ansi";
        color = true;
      };
    };
  };
}
