{lib}:
with lib; {
  mkOpt = type: default: description:
    mkOption {inherit type default description;};
}
