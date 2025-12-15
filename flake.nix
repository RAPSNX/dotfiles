{
  description = "Nix Schmix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-git = {
      url = "github:hyprwm/hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neonix = {
      url = "github:rgroemmer/neonix";
    };
    krewfile = {
      url = "github:brumhard/krewfile";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    pre-commit-hooks,
    ...
  }: let
    inherit (self) outputs;
    lib = nixpkgs.lib // home-manager.lib;

    systems = [
      "aarch64-linux"
      "x86_64-linux"
    ];
    pkgsFor = lib.genAttrs systems (
      system:
        import nixpkgs {
          inherit system;
          overlays = [(import ./overlays)];
        }
    );
    forAllSystems = f: lib.genAttrs systems (system: f pkgsFor.${system});
  in {
    inherit lib;

    formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
    devShells = forAllSystems (pkgs: import ./dev-shells.nix {inherit pkgs pre-commit-hooks;});
    packages = forAllSystems (pkgs: import ./packages {inherit pkgs;});

    nixosConfigurations = {
      # Main workstation
      zion = lib.nixosSystem {
        modules = [./hosts/zion];
        specialArgs = {inherit inputs outputs;};
      };
      # K3S home-lab
      # FIXME: Fix refactoring for kubex, check nixpkgs-stable and diff before update.
      kubex = lib.nixosSystem {
        modules = [./hosts/kubex];
        specialArgs = {inherit inputs outputs;};
      };
      # Raspberry-pi 3
      # FIXME: Fix refactoring for kubex, check nixpkgs-stable and diff before update.
      nixberry = lib.nixosSystem {
        modules = [./hosts/nixberry];
        specialArgs = {inherit inputs outputs;};
      };
      # ISO multi-tool
      vinox = lib.nixosSystem {
        modules = [./hosts/vinox];
        specialArgs = {inherit inputs outputs;};
      };
    };

    homeConfigurations = {
      # Main workstation
      "rap@zion" = lib.homeManagerConfiguration {
        modules = [./modules/home-manager/zion.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      # Firefly workmachine
      "rapsn@firefly" = lib.homeManagerConfiguration {
        modules = [./modules/home-manager/firefly.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit self inputs outputs;};
      };
    };
  };
}
