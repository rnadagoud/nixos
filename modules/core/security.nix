{ config, pkgs, ... }:

{
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 2222 ];

  services.openssh.enable = true;
  services.openssh.port = 2222;
  services.openssh.passwordAuthentication = false;

  services.fail2ban.enable = true;

  # Keep sudo requiring a password for wheel
  security.sudo.wheelNeedsPassword = true;
}
