{
  lib,
  mylib,
  pkgs,
  config,
  ...
}:
{
  options.roles = {
    work = lib.mkEnableOption "Device is used for work.";
    email = mylib.mkOpt lib.types.str "Email address of the user.";

    apparmor-gen =
      mylib.mkOpt' (lib.types.listOf lib.types.package) [ ]
        "List of packages to create apparmor rule for userns.";
  };

  config =
    let
      apparmorRule = app: path: ''
        # Warning this is auto-generated apparmor profile via nix.
        abi <abi/4.0>,
        include <tunables/global>

        profile ${app}-nix ${path} flags=(unconfined) {
          userns,
        }
      '';

      apparmorProfiles = map (pkg: {
        app = pkg.pname;
        path = lib.getExe pkg;
        content = pkgs.writeText "${pkg.pname}-apparmor-profile" (apparmorRule pkg.pname (lib.getExe pkg));
      }) config.roles.apparmor-gen;

      apparmorSetupScript = pkgs.writeShellScript "apparmor-gen" ''
        set -eu
        ${lib.strings.concatLines (
          map (profile: ''
            cp -f ${profile.content} /etc/apparmor.d/${profile.app}-nix
          '') apparmorProfiles
        )}
        if command -v systemctl >/dev/null 2>&1; then
          systemctl reload apparmor || true
        fi
      '';

      noisetorchExe = lib.getExe pkgs.noisetorch;
      setcapExe = lib.getExe' pkgs.libcap "setcap";
      getcapExe = lib.getExe' pkgs.libcap "getcap";
      cmpExe = lib.getExe' pkgs.diffutils "cmp";
    in
    lib.mkIf (config.roles.apparmor-gen != [ ] || config.roles.work) {
      home.activation.roles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${lib.optionalString (config.roles.apparmor-gen != [ ]) ''
          apparmor_changed=0
          ${lib.strings.concatLines (
            map (profile: ''
              if ! ${cmpExe} --silent ${profile.content} /etc/apparmor.d/${profile.app}-nix 2>/dev/null; then
                apparmor_changed=1
              fi
            '') apparmorProfiles
          )}
          if [[ $apparmor_changed -eq 1 ]]; then
            warnEcho "AppArmor profiles require an update, run"
            warnEcho "  sudo ${apparmorSetupScript}"
          fi
        ''}
        ${lib.optionalString config.roles.work ''
          if [[ "$(${getcapExe} ${noisetorchExe} 2>/dev/null)" != "${noisetorchExe} cap_sys_resource=ep" ]]; then
            warnEcho "NoiseTorch capabilities are missing, run"
            warnEcho "  sudo ${setcapExe} 'CAP_SYS_RESOURCE=+ep' ${noisetorchExe}"
          fi
        ''}
      '';
    };
}
