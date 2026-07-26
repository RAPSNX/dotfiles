{ pkgs, ... }:
let
  generalBinding = {
    key = "H";
    mods = "Control";
  };

  kubernetesBinding = {
    key = "K";
    mods = "Control";
  };

  # Keep these as one alternation per mode. This prevents overlapping matches
  # such as a hostname inside a URL from producing duplicate hint labels.
  generalRegex = ''(?-u)(?:ipfs:|ipns:|magnet:|mailto:|gemini://|gopher://|https://|http://|news:|file:|git://|ssh://|ftp://)[^[:space:]<>"\x27{}^\x60]+|[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}|(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(?:\.(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}|\[(?:[0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}\]|(?:[0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}|[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}|\b[0-9a-fA-F]{7,40}\b|(?:~|\.{1,2})/[^[:space:]<>"\x27\x60]+|/(?:home|etc|var|tmp|usr|opt|run|dev|mnt|root)/[^[:space:]<>"\x27\x60]+|\b(?:[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?\.)+[A-Za-z]{2,}\b|\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+:[^[:space:]<>"\x27\x60]+'';

  kubernetesRegex = ''(?-u)\b[a-z0-9](?:[a-z0-9._-]*[a-z0-9])*(?::[A-Za-z0-9._-]+|@sha256:[0-9a-fA-F]{64})\b|\b[a-z0-9](?:[a-z0-9._-]*[a-z0-9])?(?:/[a-z0-9](?:[a-z0-9._-]*[a-z0-9])?)+(?::[A-Za-z0-9._-]+|@sha256:[0-9a-fA-F]{64})\b|(?:pods?|deployments?|statefulsets?|daemonsets?|jobs?|cronjobs?|replicasets?|services?|svc|ingresses?|configmaps?|cm|secrets?|namespaces?|ns|nodes?|no|events?|ev|serviceaccounts?|sa|roles?|rolebindings?|customresourcedefinitions?|crds?|shoots?|seeds?|managedseeds?|projects?|clusters?|cloudprofiles?|backupbuckets?|backupentries?|bastions?|containerruntimes?|controlplanes?|dnsrecords?|extensions?|infrastructures?|networks?|operatingsystemconfigs?|workers?|machinedeployments?|machinesets?|machines?|machineclasses?)/[a-z0-9][a-z0-9.-]*[a-z0-9]|(?:context|ctx|namespace|ns)[=:][[:space:]]*[A-Za-z0-9][A-Za-z0-9._-]*|(?:--context|--namespace|-n)[=:[:space:]]*[A-Za-z0-9][A-Za-z0-9._-]*|(?:[a-z0-9](?:[-a-z0-9]*[a-z0-9])?\.)+[a-z0-9](?:[-a-z0-9]*[a-z0-9])?/[A-Za-z0-9][A-Za-z0-9_.-]*(?:[=:][[:space:]]*[A-Za-z0-9_.:/-]+)?|\b[A-Za-z][A-Za-z0-9_.-]*=[A-Za-z0-9_.:/-]+\b|\b[A-Za-z0-9-]+(?:\.[A-Za-z0-9-]+)*\.svc(?:\.cluster\.local)?\b|(?:\[[0-9A-Fa-f:]+\]|(?:[A-Za-z0-9-]+\.)+[A-Za-z0-9-]+|(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(?:\.(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])){3}):[0-9]{1,5}'';

in
{
  home.packages = [
    pkgs.nerd-fonts.caskaydia-cove
  ];

  fonts.fontconfig.enable = true;

  programs.alacritty = {
    enable = true;
    package = pkgs.alacritty;
    settings = {
      terminal.shell.program = "zsh";
      env.TERM = "xterm-256color";

      selection = {
        save_to_clipboard = true;
      };

      window = {
        padding = {
          x = 3;
          y = 3;
        };
      };

      hints.enabled = [
        # General copy hints: links, network identifiers, paths, and Git
        # artifacts without matching arbitrary hyphenated words.
        {
          action = "Copy";
          binding = generalBinding;
          hyperlinks = true;
          post_processing = true;
          regex = generalRegex;
        }

        # Kubernetes and Gardener copy hints: resources, selectors,
        # annotations, contexts, namespaces, endpoints, and images.
        {
          action = "Copy";
          binding = kubernetesBinding;
          post_processing = true;
          regex = kubernetesRegex;
        }
      ];

      font =
        let
          fontname = "CaskaydiaCove Nerd Font";
        in
        {
          normal = {
            family = fontname;
            style = "SemiBold";
          };
          bold = {
            family = fontname;
            style = "Bold";
          };
          italic = {
            family = fontname;
            style = "Italic";
          };
          size = 12;
        };

      mouse.bindings = [
        {
          mouse = "Right";
          action = "Paste";
        }
      ];
    };
  };
}
