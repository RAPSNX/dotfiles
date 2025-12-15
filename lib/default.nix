{ lib }:
with lib;
{
  mkOpt = type: description: mkOption { inherit type description; };

  mkOpt' =
    type: default: description:
    mkOption { inherit type default description; };
}
