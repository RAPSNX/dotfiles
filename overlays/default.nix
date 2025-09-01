_: prev: {
  python313Packages = prev.python313Packages.overrideScope (_: super: {
    i3ipc = super.i3ipc.overridePythonAttrs (_: {
      doCheck = false;
    });
  });
}
