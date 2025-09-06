{
  reconcile = {
    description = "Reconcile resource";
    shortCut = "r";
    scopes = [
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
    command = "kubectl";
    background = true;
    args = [
      "annotate"
      "-n"
      "$NAMESPACE"
      "$RESOURCE_NAME"
      "$NAME"
      "gardener.cloud/operation=reconcile"
    ];
  };

  reconcile-seed = {
    description = "Reconcile seed";
    shortCut = "r";
    scopes = ["managedseeds"];
    command = "kubectl";
    background = true;
    args = [
      "annotate"
      "$RESOURCE_NAME"
      "$NAME"
      "gardener.cloud/operation=reconcile"
    ];
  };

  retry-shoot = {
    description = "Retry shoot operation";
    shortCut = "t";
    scopes = ["shoots"];
    command = "kubectl";
    background = true;
    args = [
      "annotate"
      "-n"
      "$NAMESPACE"
      "$RESOURCE_NAME"
      "$NAME"
      "gardener.cloud/operation=retry"
    ];
  };

  confirm-deletion = {
    description = "Confirm deletion";
    shortCut = "o";
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
    background = false;
    args = [
      "annotate"
      "-n"
      "$NAMESPACE"
      "$RESOURCE_NAME"
      "$NAME"
      "confirmation.gardener.cloud/deletion=true"
    ];
  };
}
