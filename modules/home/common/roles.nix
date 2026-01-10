{
  lib,
  mylib,
  pkgs,
  config,
  ...
}:
with lib;
with mylib;
with types;
{
  options.roles = {
    work = mkEnableOption "Device is used for work.";
    email = mkOpt str "Email address of the user.";

    apparmor-gen = mkOpt' (listOf package) [ ] "List of packages to create apparmor rule for userns.";
  };

  config =
    let
      apparmorRuleGen = app: path: ''
        cat <<EOF >/etc/apparmor.d/${app}-nix
        # Warning this is auto-generated apparmor profile via nix.
        abi <abi/4.0>,
        include <tunables/global>

        profile ${app}-nix ${path} flags=(unconfined) {
          userns,
        }
        EOF
      '';

      apparmorProfilesGen = strings.concatStrings (
        (map (pkg: apparmorRuleGen pkg.pname (lib.getExe pkg)) config.roles.apparmor-gen)
        ++ [ "sudo systemctl reload apparmor" ]
      );
    in
    mkIf (config.roles.apparmor-gen != [ ]) {
      home.activation.apparmor-gen = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run warnEcho "sudo ${pkgs.writeShellScript "apparmor-gen" apparmorProfilesGen}"
      '';
    };
}
