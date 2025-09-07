{
  description = "NixOS configuration for development workstation";

  inputs = {
    # Core NixOS
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hyprland
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hardware specific
    hardware.url = "github:NixOS/nixos-hardware";
    
    # Development tools
    devenv.url = "github:cachix/devenv";
    
    # Secrets management
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, hardware, devenv, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            # Main system configuration
            ./system/configuration.nix
            ./system/hardware.nix
            ./system/disk-setup.nix
            ./system/hyprland.nix
            ./system/backup.nix
            ./system/power-management.nix
            
            # Hardware specific
            hardware.nixosModules.common-cpu-amd
            hardware.nixosModules.common-gpu-nvidia
            
            # Hyprland
            hyprland.nixosModules.default
            { programs.hyprland.enable = true; }
            
            # Sops for secrets
            sops-nix.nixosModules.sops
            
            # Home Manager integration
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = import ./home/home.nix;
            }
          ];
        };
      };
    };
}