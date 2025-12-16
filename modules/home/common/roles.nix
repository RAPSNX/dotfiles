{ lib, mylib, ... }:
with lib;
with mylib;
{
  options.roles = with types; {
    work = mkEnableOption "Device is used for work.";
    email = mkOpt str "Email address of the user.";
  };
}
