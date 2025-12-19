{
  # Minimal hardware configuration scaffold for `nvme0n1` with EFI + root + home
  # NOTE: The device names below are placeholders. Adjust `/dev/nvme0n1p1` etc. to match
  # the real partitions after you partition the disk (e.g., with disko or parted).

  fileSystems."/" = {
    device = "/dev/nvme0n1p2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/nvme0n1p3";
    fsType = "ext4";
  };

  swapDevices = [ { device = "/swapfile"; size = 8192; } ];

  # Example: if you'd rather use LVM or encryption, replace this with a disko
  # generated hardware-configuration.nix. This file intentionally keeps things
  # simple and unencrypted, per your instructions.
}
