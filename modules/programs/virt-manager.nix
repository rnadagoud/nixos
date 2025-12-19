{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  virtualisation.libvirtd.packages = with pkgs; [ virt-manager ];
  users.extraGroups.libvirt.members = [ "rahul" ];
}
