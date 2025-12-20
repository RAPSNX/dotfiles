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

      nixosModules = [
        inputs.catppuccin.nixosModules.catppuccin
        (inputs.import-tree.match ".*/default\\.nix" ./modules/nixos)
        ./modules/nix.nix
      ];

      homeModules = [
        inputs.catppuccin.homeModules.catppuccin
        inputs.neonix.homeManagerModules.neonix
        inputs.krewfile.homeManagerModules.krewfile
        inputs.sops-nix.homeManagerModules.sops
        (inputs.import-tree.match ".*/default\\.nix" ./modules/home)
        ./modules/nix.nix
      ];
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
          modules = nixosModules ++ [ ./hosts/zion ];
          specialArgs = { inherit inputs mylib; };
        };

        # K3S home-lab
        kubex = nixosSystem {
          modules = nixosModules ++ [ ./hosts/kubex ];
          specialArgs = { inherit inputs mylib; };
        };

        # Raspberry-pi 3
        nixberry = nixosSystem {
          modules = nixosModules ++ [ ./hosts/nixberry ];
          specialArgs = { inherit inputs mylib; };
        };

        # ISO multi-tool
        vinox = nixosSystem {
          modules = nixosModules ++ [ ./hosts/vinox ];
          specialArgs = { inherit inputs mylib; };
        };
      };

      homeConfigurations = {
        # Main workstation
        "rap@zion" = homeManagerConfiguration {
          modules = homeModules ++ [ ./hosts/zion/home.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs self mylib; };
        };

        # Firefly workmachine
        "rapsn@firefly" = homeManagerConfiguration {
          modules = homeModules ++ [ ./hosts/firefly/home.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs self mylib; };
        };
      };
    };
}
