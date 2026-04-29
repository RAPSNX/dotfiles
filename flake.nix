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

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nfsm = {
      # Niri fullscreen manager
      url = "github:gvolpe/nfsm";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

      overlays = [
        (import ./overlays)
        inputs.niri.overlays.niri
      ];

      pkgsFor = lib.genAttrs systems (
        system:
        import nixpkgs {
          inherit system overlays;
        }
      );

      forAllSystems = f: lib.genAttrs systems (system: f pkgsFor.${system});

      nixosModules = [
        inputs.catppuccin.nixosModules.catppuccin
        inputs.niri.nixosModules.niri
        (inputs.import-tree.match ".*/default\\.nix" ./modules/nixos)
        ./modules/nix.nix
      ];

      homeModules = [
        inputs.catppuccin.homeModules.catppuccin
        inputs.neonix.homeManagerModules.neonix
        inputs.krewfile.homeManagerModules.krewfile
        inputs.niri.homeModules.niri
        (inputs.import-tree.match ".*/default\\.nix" ./modules/home)
        ./modules/nix.nix
      ];
    in
    {
      inherit lib;

      formatter = forAllSystems (pkgs: pkgs.nixfmt);

      devShells = forAllSystems (pkgs: import ./dev-shells.nix { inherit pkgs pre-commit-hooks; });
      packages = forAllSystems (pkgs: import ./packages { inherit pkgs; });

      nixosConfigurations = {
        # Main workstation
        zion = lib.nixosSystem {
          modules = nixosModules ++ [ ./hosts/zion ];
          specialArgs = { inherit inputs mylib; };
        };

        # K3S home-lab
        kubex = lib.nixosSystem {
          modules = nixosModules ++ [ ./hosts/kubex ];
          specialArgs = { inherit inputs mylib; };
        };

        # Raspberry-pi 3
        nixberry = lib.nixosSystem {
          modules = nixosModules ++ [ ./hosts/nixberry ];
          specialArgs = { inherit inputs mylib; };
        };

        # ISO multi-tool
        vinox = lib.nixosSystem {
          modules = nixosModules ++ [ ./hosts/vinox ];
          specialArgs = { inherit inputs mylib; };
        };
      };

      homeConfigurations = {
        # Main workstation
        "rap@zion" = lib.homeManagerConfiguration {
          modules = homeModules ++ [ ./hosts/zion/home.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs self mylib; };
        };

        # Firefly workmachine
        "nix@firefly" = lib.homeManagerConfiguration {
          modules = homeModules ++ [ ./hosts/firefly/home.nix ];
          pkgs = pkgsFor.x86_64-linux;
          extraSpecialArgs = { inherit inputs self mylib; };
        };
      };
    };
}
