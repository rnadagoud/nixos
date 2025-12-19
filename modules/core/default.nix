{ config, pkgs, ... }:

{
  imports = [
    ./boot.nix
    ./network.nix
    ./nix.nix
    ./security.nix
    ./fonts.nix
  ];

  # Common system packages (merged with host-specific packages)
  environment.systemPackages = with pkgs; [
    git vim wget
  ];

  # Enable hyprland by default according to your preference - the desktop module
  # may add more Hyprland specific configuration later.
  services.hyprland = { enable = true; };
}
