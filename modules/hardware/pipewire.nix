{ config, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    package = pkgs.pipewire;
  };

  environment.systemPackages = with pkgs; [ pipewire wireplumber ];
}
