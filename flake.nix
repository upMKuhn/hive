{
  description = "The Hive - The secretly open NixOS-Society";
  inputs.std.url = "github:divnix/std";
  inputs.std.inputs.nixpkgs.follows = "nixpkgs";
  inputs.std.inputs.mdbook-kroki-preprocessor.follows = "std/blank";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  # tools
  inputs = {
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "std/blank";
    nixos-generators.inputs.nixlib.follows = "nixpkgs";
    colmena.url = "github:blaggacao/colmena";
    colmena.inputs.nixpkgs.follows = "nixpkgs";
    colmena.inputs.stable.follows = "std/blank";
    colmena.inputs.flake-utils.follows = "std/flake-utils";
  };

  # nixpkgs & home-manager
  inputs = {
    nixos.follows = "nixos-22-05";
    home.follows = "home-22-05";

    nixos-22-05.url = "github:nixos/nixpkgs/release-22.05";
    home-22-05.url = "github:nix-community/home-manager/release-22.05";
    nixos-21-11.url = "github:nixos/nixpkgs/release-21.11";
    home-21-11.url = "github:blaggacao/home-manager/release-21.11-with-nix-profile";
  };

  # individual extra inputs
  inputs = {
  };

  outputs = {
    std,
    self,
    ...
  } @ inputs: let
    # exports have no system, pick one
    exports = self.x86_64-linux;
  in
    std.growOn {
      inherit inputs;
      cellsFrom = ./comb;
      # debug = ["cells" "x86_64-linux"];
      cellBlocks = with std.blockTypes; [
        # modules implement
        (functions "nixosModules")
        (functions "homeModules")
        (functions "devshellModules")

        # profiles activate
        (functions "nixosProfiles")
        (functions "homeProfiles")
        (functions "devshellProfiles")

        # suites aggregate profiles
        (functions "nixosSuites")
        (functions "homeSuites")

        # configurations can be deployed
        (data "colmenaConfigurations")
        (data "homeConfigurations")

        # devshells can be entered
        (devshells "devshells")

        # jobs can be run
        (runnables "jobs")

        # library holds shared knowledge made code
        (functions "library")
      ];
    }
    # soil - the first (and only) layer implements adapters for tooling
    {
      # tool: colmena
      colmenaHive = let
        makeHoneyFrom = import ./make-honey.nix {
          inherit (inputs) colmena nixpkgs;
          cellBlock = "colmenaConfigurations";
        };
      in
        makeHoneyFrom self;
    };

  # --- Flake Local Nix Configuration ----------------------------
  # TODO: adopt spongix
  nixConfig = {
    extra-substituters = [];
    extra-trusted-public-keys = [];
  };
  # --------------------------------------------------------------
}
