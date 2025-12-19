{
  description = "Personal NixOS configuration (flake) for rahul";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager";
    disko.url = "github:nix-community/disko";
    nixos-hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, flake-utils, home-manager, disko, nixos-hardware, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      nixosConfigurations."nixos-btw" = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./hosts/desktop/configuration.nix
          ./hosts/desktop/hardware-configuration.nix
          ./modules/core/default.nix
        ];
        specialArgs = { inherit self home-manager disko nixos-hardware; };
      };

      # small convenience package set
      packages.${system}.default = pkgs.hello;
    };
}