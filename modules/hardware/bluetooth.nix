{ config, pkgs, ... }:

{
  services.bluez.enable = true;
  hardware.bluetooth = { enable = true; };
  environment.systemPackages = with pkgs; [ bluez bluez-utils ];
}
