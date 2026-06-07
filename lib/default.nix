{ lib }:
{
  mkOpt = type: description: lib.mkOption { inherit type description; };

  mkOpt' =
    type: default: description:
    lib.mkOption { inherit type default description; };

}
