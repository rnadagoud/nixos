{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.configurationLimit = 5;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Install AMD microcode package to ensure CPU microcode updates on AMD systems
  environment.systemPackages = with pkgs; [ amd-ucode ];
}
