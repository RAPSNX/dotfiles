## Nix follows

```
    neonix = {
      url = "github:rgroemmer/neonix/plugin-enhancement";
      inputs.nixpkgs.follows = "nixpkgs";
    };
```

This will follow the actual flakes `nixpkgs`, neonix by itself uses `nixvim` from its own inputs, which is not part
of `nixpkgs`.
If the flakes `nixpkgs` is to new, plugins and packages from it will be "to new" for the rather outdated `nixvim` from neonix repo.
This can lead to problems starting nvim, this can be fixed by update the `neonix` flake accordingly.
> There is also a nix (lix?) bug, which does not update the `flake.lock` when a follows is removed.

## Neonix

`neonix` needs to have its own `nixpkgs`, so no `nixpkgs.follows` is configured.
Instead this should be updated on its own, because if nixpkgs in dotfiles is to new, all dependencies and plugins of 
nvim may not work anymore with the `neonix` upstream configuration.
