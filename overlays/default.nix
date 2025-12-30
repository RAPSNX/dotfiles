final: _: {
  # Example overlay
  # python313Packages = prev.python313Packages.overrideScope (_: super: {
  #   i3ipc = super.i3ipc.overridePythonAttrs (_: {
  #     doCheck = false;
  #   });
  # });

  # Add my own packages also to pkgs
  # Use final here, to provide the "final" dependencies to build my packages.
  mypkgs = import ../packages {pkgs = final;};
}
