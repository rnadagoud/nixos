{ config, pkgs, ... }:

{
  # Provide system-wide git (user-level config managed via Home Manager)
  environment.systemPackages = with pkgs; [ git ];
}
