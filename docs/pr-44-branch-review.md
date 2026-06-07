# PR #44 branch review notes

This document captures the textual review points for the `Restructure :soap: Cillit Bang :bangbang:` follow-up branch.

## What improved

- `modules/nixos/system/env.nix` now binds `lib` explicitly, so `lib.attrValues` and `lib.optionals` resolve from the NixOS module argument set instead of relying on a `with pkgs;` scope.
- `hosts/nixberry/default.nix` no longer imports the removed `../../modules/nixos` path. The host now relies on the shared `nixosModules` list assembled in `flake.nix`, matching the other NixOS hosts.
- Package lists are now mostly standardized on `lib.attrValues { inherit (...) ...; }`, which avoids `with pkgs;` shadowing and makes package origins explicit.
- The Steam `extraPkgs` callback was also converted from `p: with p; ...` to `p: lib.attrValues { inherit (p) ...; }`, so the same style applies in nested package scopes.
- Existing `builtins.attrValues` package collections were moved to `lib.attrValues` for consistency.

## Review comments to add

### Ordering semantics of `lib.attrValues`

`lib.attrValues` is not exactly equivalent to a hand-written list: values are returned in attribute-name order rather than the order written in the original list. This is usually fine for package collections, but it can matter if two packages provide the same binary and PATH precedence is important. The broad core and diagnostics package sets are worth keeping in mind for this.

### Remaining non-`attrValues` package list

The branch removes the leftover `with` usage, but `modules/nixos/roles/desktop/explorer.nix` still has a direct single-item package list for `pkgs.file-roller`. This is not a shadowing problem, but if the desired convention is "all package lists use `lib.attrValues`", it should be converted too.

### `dev-shells.nix` lib source

`dev-shells.nix` now defaults to `lib ? pkgs.lib`, while `flake.nix` defines a combined `lib = nixpkgs.lib // home-manager.lib`. This works for `lib.attrValues`, but passing the flake-level `lib` into `dev-shells.nix` would be more consistent if the combined library is intended to be used everywhere.

### Readability of large one-line inherit groups

The `lib.attrValues` style is good, but some large groups are now very dense. Consider multi-line `inherit (pkgs)` blocks for larger package groups to keep diffs and comments readable.

### Testing and formatting still need local/CI confirmation

The branch should be validated with the repo's Nix tooling before merge:

```bash
nix flake check
nix build .#nixosConfigurations.nixberry.config.system.build.toplevel
nix build .#nixosConfigurations.zion.config.system.build.toplevel
nix fmt
statix check
deadnix
```

These checks are especially important because the branch touches many module argument sets and package collections.

### PR scope

The branch now combines correctness fixes with a broad style refactor. That is acceptable because the follow-up request asked for repository-wide cleanup, but reviewers should be aware that the style portion is much larger than the original evaluation bug fix.

## Suggested follow-up changes

- Convert the remaining direct `environment.systemPackages = [ pkgs.file-roller ];` package list to `lib.attrValues` if strict consistency is desired.
- Pass `lib` into `dev-shells.nix` from `flake.nix`, or intentionally keep the current `lib ? pkgs.lib` default if standalone import compatibility is preferred.
- Consider formatting larger package groups as multi-line `inherit` blocks.
- Run the full Nix checks listed above in an environment with Nix installed.
