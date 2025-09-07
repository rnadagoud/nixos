{ config, pkgs, ... }:

{
  # LUKS encryption with TPM disk unlocking
  # This file contains the disk setup configuration
  
  # Boot configuration for encrypted system
  boot.initrd = {
    systemd.enable = true;
    supportedFilesystems = [ "btrfs" ];
    luks = {
      devices = {
        "luksroot" = {
          device = "/dev/disk/by-uuid/YOUR_ROOT_UUID"; # Replace with actual UUID
          allowDiscards = true;
          keyFile = "/crypto_keyfile.bin";
          fallbackToPassword = true;
        };
      };
    };
  };
  
  # TPM integration for automatic unlocking
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    abrmd.enable = true;
  };
  
  # Enable systemd-cryptenroll for TPM enrollment
  systemd.services.cryptenroll = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0,2,4,7 /dev/disk/by-uuid/YOUR_ROOT_UUID";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
  
  # Filesystem configuration
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/YOUR_ROOT_UUID";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" "noatime" ];
    };
    
    "/home" = {
      device = "/dev/disk/by-uuid/YOUR_ROOT_UUID";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" ];
    };
    
    "/nix" = {
      device = "/dev/disk/by-uuid/YOUR_ROOT_UUID";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" ];
    };
    
    "/var/log" = {
      device = "/dev/disk/by-uuid/YOUR_ROOT_UUID";
      fsType = "btrfs";
      options = [ "subvol=@log" "compress=zstd" "noatime" ];
    };
    
    "/boot" = {
      device = "/dev/disk/by-uuid/YOUR_BOOT_UUID"; # Replace with actual UUID
      fsType = "vfat";
    };
  };
  
  # Swap configuration for hibernation
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/YOUR_SWAP_UUID"; # Replace with actual UUID
      randomEncryption = true;
    }
  ];
  
  # Hibernation configuration
  boot.kernelParams = [
    "resume=UUID=YOUR_SWAP_UUID" # Replace with actual UUID
    "resume_offset=0"
  ];
  
  # Enable hibernation
  powerManagement.enable = true;
  services.logind.extraConfig = ''
    HandleSuspendKey=hibernate
    HandleLidSwitch=hibernate
  '';
}