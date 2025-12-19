{
  # Example disko configuration for `/dev/nvme0n1` (EFI + root + home, no encryption)
  # Use `nix run github:nix-community/disko -- --help` to apply.

  disk = {
    device = "/dev/nvme0n1";
    schema = [
      { name = "EFI"; size = 512; fsType = "vfat"; mountPoint = "/boot"; type = "efi"; }
      { name = "ROOT"; size = 0; fsType = "ext4"; mountPoint = "/"; }
      { name = "HOME"; size = 0; fsType = "ext4"; mountPoint = "/home"; }
    ];
  };

  # Note: This is a template — verify partition numbers and reorder sizes for your disk.
}
