{ config, pkgs, ... }:

{
  # Basic boot setup for almost any system
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "rescue";
  time.timeZone = "Asia/Kolkata";

  # US English locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" ];
  i18n.extraLocaleSettings = { LC_TIME = "en_GB.UTF-8"; };

  # Filesystem: you can use ext4 for /, ignore Btrfs, LUKS, etc.
  fileSystems."/" = {
    device = "/dev/nvme0n1p2"; # or your root, use ext4!
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;
  hardware.opengl.enable = true;

  users.users.rahul = {
    isNormalUser = true;
    password = "nixos";
    shell = pkgs.bash;
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # Network and basic internet tools
  networking.networkmanager.enable = true;
  environment.systemPackages = with pkgs; [
    wget curl git firefox gparted dd
  ];

  # Quick rescue utilities
  system.stateVersion = "25.05";
}
