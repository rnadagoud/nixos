{ config, pkgs, ... }:

let
  # home-manager is available via flake specialArgs; import its nixos module so we can
  # declare `home-manager.users` below.
  hm = import (home-manager + "/nixos") { inherit pkgs; };
in

{
  imports = [
    hm.nixosModule
    ./hardware-configuration.nix
    ../../modules/core/default.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/niri.nix
    ./disko.nix
  ];

  networking.hostName = "nixos-btw";
  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  # Bootloader & kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.configurationLimit = 5;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Users
  users.users.rahul = {
    isNormalUser = true;
    description = "Rahul Nadagoud";
    extraGroups = [ "wheel" "audio" "video" "docker" "libvirt" ];
    home = "/home/rahul";
    shell = pkgs.fish;
    # Password is intentionally left unset — set one after deployment.
    password = null; 

  # SSH
  services.openssh.enable = true;
  services.openssh.port = 2222;
  services.openssh.passwordAuthentication = false;

  # Networking
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 2222 ];

  # Display & desktop
  services.gdm.enable = true;
  services.gdm.wayland = true;
  services.hyprland.enable = true;

  # Audio, bluetooth
  services.pipewire.enable = true;
  services.bluez.enable = true;

  # Virtualization & containers
  virtualisation.libvirtd.enable = true;
  services.docker.enable = true;

  # Packages
  environment.systemPackages = with pkgs; [
    vim git wget
    firefox
    kitty
    vscode
    zoxide fastfetch bat ripgrep fd btop ncdu curl unzip
    pciutils usbutils
    eza nix-tree alejandra
    amd-ucode
  ];

  # Swap file
  swapDevices = [ { device = "/swapfile"; size = 8192; } ];

  # Home Manager per-user configuration
  home-manager.users.rahul = {
    programs.fish.enable = true;
    programs.fish.defaultShell = true;
    programs.git = {
      enable = true;
      userName = "Rahul Nadagoud";
      userEmail = "nadagoud@pm.me";
    };
    home.packages = with pkgs; [ fish nerd-fonts.jetbrains-mono ];
  };

  # Notes: hardware devices and fileSystems are defined in hardware-configuration.nix
}
