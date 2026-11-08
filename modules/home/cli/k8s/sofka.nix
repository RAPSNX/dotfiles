{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  gardenerScopes = [
    "shoots"
    # all resources in extensions.gardener.cloud/v1alpha1
    "backupbuckets"
    "backupentries"
    "bastions"
    "clusters"
    "containerruntimes"
    "controlplanes"
    "dnsrecords"
    "extensions"
    "infrastructures"
    "networks"
    "operatingsystemconfigs"
    "workers"
  ];

  defaultPlugins = [
    {
      name = "edit-secret";
      key = "ctrl-x";
      scopes = [ "secrets" ];
      command = "kubectl";
      args = [
        "modify-secret"
        "-n"
        "$NAMESPACE"
        "$NAME"
      ];
    }
  ];

  workPlugins = [
    {
      name = "reconcile";
      key = "ctrl-g";
      scopes = gardenerScopes;
      command = "kubectl";
      output = "background";
      args = [
        "annotate"
        "-n"
        "$NAMESPACE"
        "$RESOURCE"
        "$NAME"
        "gardener.cloud/operation=reconcile"
      ];
    }
    {
      name = "reconcile-seed";
      key = "ctrl-g";
      scopes = [ "managedseeds" ];
      command = "kubectl";
      output = "background";
      args = [
        "annotate"
        "$RESOURCE"
        "$NAME"
        "gardener.cloud/operation=reconcile"
      ];
    }
    {
      name = "retry-shoot";
      key = "ctrl-t";
      scopes = [ "shoots" ];
      command = "kubectl";
      output = "background";
      args = [
        "annotate"
        "-n"
        "$NAMESPACE"
        "$RESOURCE"
        "$NAME"
        "gardener.cloud/operation=retry"
      ];
    }
    {
      name = "confirm-deletion";
      key = "ctrl-o";
      scopes = [
        "projects"
        "extensions"
        "shoots"
        "backupentries"
        "etcds"
        "infrastructure"
        "controlplanes"
        "machinedeployments"
        "machinesets"
        "machineclasses"
        "namespaces"
        "worker"
        "dnsrecords"
        "operatingsystemconfig"
      ];
      command = "kubectl";
      args = [
        "annotate"
        "-n"
        "$NAMESPACE"
        "$RESOURCE"
        "$NAME"
        "confirmation.gardener.cloud/deletion=true"
      ];
    }
  ];

  plugins = defaultPlugins ++ lib.optionals config.roles.work workPlugins;
in
{
  home.packages = [
    inputs.sofka.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  xdg.configFile."sofka/config.toml".text = ''
    default_resource = "pods"

    [aliases]
    dp = "deployments"
    sec = "v1/secrets"
    jo = "jobs"
    cr = "clusterroles"
    crb = "clusterrolebindings"
    ro = "roles"
    rb = "rolebindings"
    np = "networkpolicies"

    [skin]
    name = "catppuccin-mocha"
    background = true

    ${lib.concatMapStringsSep "\n\n" (plugin: ''
      [[plugins]]
      name = "${plugin.name}"
      key = "${plugin.key}"
      scopes = [${lib.concatMapStringsSep ", " (scope: " \"${scope}\"") plugin.scopes} ]
      command = "${plugin.command}"
      ${lib.optionalString (plugin ? output) "output = \"${plugin.output}\""}
      args = [${lib.concatMapStringsSep ", " (arg: " \"${arg}\"") plugin.args} ]
    '') plugins}
  '';
}
