{ config, pkgs, ... }:

{
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Add nix-community cache as a substituter (you may need to add the
  # corresponding trusted-public-keys if you use this cache).
  nix.settings.substituters = [ "https://cache.nixos.org/" "https://cache.nix-community.org/" ];
}
