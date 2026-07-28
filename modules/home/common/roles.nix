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

      apparmorRuleGen = app: path: ''
        cat <<EOF >/etc/apparmor.d/${app}-nix
        ${apparmorRule app path}EOF
      '';

      apparmorProfiles = map (pkg: {
        app = pkg.pname;
        path = lib.getExe pkg;
        content = pkgs.writeText "${pkg.pname}-apparmor-profile" (apparmorRule pkg.pname (lib.getExe pkg));
      }) config.roles.apparmor-gen;

      apparmorProfilesGen = lib.strings.concatStrings (
        (map (profile: apparmorRuleGen profile.app profile.path) apparmorProfiles)
        ++ [ "sudo systemctl reload apparmor" ]
      );

      apparmorProfilesChanged = pkgs.writeShellScript "apparmor-profiles-changed" ''
        ${lib.strings.concatStringsSep "\n" (
          map (profile: ''
            if ! ${lib.getExe' pkgs.diffutils "cmp"} --silent ${profile.content} /etc/apparmor.d/${profile.app}-nix; then
              exit 0
            fi
          '') apparmorProfiles
        )}
        exit 1
      '';

      noisetorchExe = lib.getExe pkgs.noisetorch;
      noisetorchCapsSet = pkgs.writeShellScript "noisetorch-caps-set" ''
        test "$(${lib.getExe' pkgs.libcap "getcap"} ${noisetorchExe} 2>/dev/null)" = "${noisetorchExe} cap_sys_resource=ep"
      '';
    in
    lib.mkIf (config.roles.apparmor-gen != [ ] || config.roles.work) {
      home.activation.roles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${lib.optionalString (config.roles.apparmor-gen != [ ]) ''
          if ${apparmorProfilesChanged}; then
            run warnEcho "sudo ${pkgs.writeShellScript "apparmor-gen" apparmorProfilesGen}"
          fi
        ''}
        ${lib.optionalString config.roles.work ''
          if ! ${noisetorchCapsSet}; then
            run warnEcho "sudo setcap 'CAP_SYS_RESOURCE=+ep' ${noisetorchExe}"
          fi
        ''}
      '';
    };
}
