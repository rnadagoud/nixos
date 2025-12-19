{ config, pkgs, ... }:

{
  # Enable periodic fstrim to maintain SSD health
  services.fstrim.enable = true;
}
