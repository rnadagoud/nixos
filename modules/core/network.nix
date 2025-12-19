{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.hostName = "nixos-btw";
  networking.nameservers = [ "1.1.1.1" "8.8.8.8" ];
}
