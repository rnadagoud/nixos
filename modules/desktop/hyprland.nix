{ config, pkgs, ... }:

{
  # Basic Hyprland packaging and enablement; no extra user config yet.
  environment.systemPackages = with pkgs; [ hyprland wayland-utils ];
  services.hyprland.enable = true;
}
