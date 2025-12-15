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
      inputs.nixpkgs.follows = "nixpkgs";
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
    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      pre-commit-hooks,
      ...
    }:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib // home-manager.lib;
      mylib = import ./lib { inherit lib; };

      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ (import ./overlays) ];
        }
      );

      forAllSystems = f: lib.genAttrs systems (system: f pkgsFor.${system});
    in
    with lib;
    {
      inherit lib;

      formatter = forAllSystems (pkgs: pkgs.nixfmt-rfc-style);
      devShells = forAllSystems (pkgs: import ./dev-shells.nix { inherit pkgs pre-commit-hooks; });
      packages = forAllSystems (pkgs: import ./packages { inherit pkgs; });

      nixosConfigurations = {
        # Main workstation
        zion = nixosSystem {
          modules = [ ./hosts/zion ];
          specialArgs = { inherit inputs mylib; };
        };

        # K3S home-lab
        kubex = nixosSystem {
          modules = [ ./hosts/kubex ];
          specialArgs = { inherit inputs mylib; };
        };

        # Raspberry-pi 3
        nixberry = nixosSystem {
          modules = [ ./hosts/nixberry ];
          specialArgs = { inherit inputs mylib; };
        };

        # ISO multi-tool
        vinox = nixosSystem {
          modules = [ ./hosts/vinox ];
          specialArgs = { inherit inputs mylib; };
        };
      };
      # K3S home-lab
      kubex = lib.nixosSystem {
        modules = [./hosts/kubex];
        specialArgs = {inherit inputs outputs;};
      };
      # Raspberry-pi 3
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
        modules = [./hosts/zion/home.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs;};
      };
      # Firefly workmachine
      "rapsn@firefly" = lib.homeManagerConfiguration {
        modules = [./hosts/firefly/home.nix];
        pkgs = pkgsFor.x86_64-linux;
        extraSpecialArgs = {inherit self inputs outputs;};
      };
    };
  };
}
