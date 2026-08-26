# AGENTS.md

Repository guidelines and operational instructions for AI agents working in this codebase.

## Core Philosophy
- **Keep it Simple & Minimal:** Prefer straightforward, minimal solutions over clever or complex abstractions.
- **No Overengineering:** If a requested change or prompt requires broad architectural changes, excessive boilerplate, or sophisticated logic, **STOP and ask** the user before proceeding.

## Overview & Architecture
- **Nix Flake & Home-Manager:** Declarative configuration managing multi-system NixOS hosts and standalone Home-Manager targets.
- **Module Discovery:** Modules in `modules/nixos/` and `modules/home/` are automatically discovered via `import-tree`.
- **Directory Structure:**
  - `hosts/<host>/`: Host-specific entrypoints (`default.nix` for NixOS, `home.nix` for Home-Manager).
  - `modules/`: Reusable NixOS and Home-Manager modules.
  - `packages/` & `overlays/`: Custom derivations and package overrides.
  - `lib/`: Shared utility functions.

## Code Conventions & Standards
- **No `with` scopes:** Avoid `with pkgs;` or `with lib;`. Use explicit attribute access or `inherit (pkgs) ...;` / `builtins.attrValues { inherit ...; }`.
- **Module Pattern:** Define options with `lib.mkEnableOption` / `lib.mkOption` (e.g. `hostConfig.<section>.<name>`) and guard implementations with `lib.mkIf cfg { ... }`.
- **Formatting & Linting:** 
  - Formatter: `nixfmt`
  - Linters: `statix`, `deadnix`

## Validation & Testing Rules
- **Minimum Test Requirement:** Every change must at least be validated via evaluation (e.g., `nix repl .` / evaluating the flake outputs).
- **Targeted Builds:** When running a build test, only build the relevant target / current host configuration (not all hosts).
- **Multi-Host Testing:** If a change might affect multiple hosts and building all targets seems advisable, ask the user for confirmation first.

## Common Commands & Workflows
- **Format:** `nix fmt`
- **Lint / Check:** `statix check .` and `deadnix .`
- **Build / Dry Run:**
  - NixOS: `nixos-rebuild build --flake .#<host>` or `nh os build --hostname <host> .`
  - Home-Manager: `home-manager build --flake .#<user@host>` or `nh home build -c <user@host> .`
- **Git Staging Note:** Always ensure new or renamed files are tracked/staged (`git add -N <file>`), otherwise Nix Flakes will ignore them during evaluation.
