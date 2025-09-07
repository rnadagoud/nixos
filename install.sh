#!/bin/bash
set -euo pipefail

# NixOS Installation Script
# This script will help you install NixOS with the configuration

echo "🚀 NixOS Installation Script"
echo "=============================="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Please don't run this script as root"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "flake.nix" ]; then
    echo "❌ Please run this script from the directory containing flake.nix"
    exit 1
fi

echo "📋 Pre-installation Checklist:"
echo "1. Make sure you have a USB drive with NixOS installer"
echo "2. Boot from the USB drive"
echo "3. Partition your disk according to the setup below"
echo "4. Update the UUIDs in the configuration files"
echo ""

# Disk partitioning guide
echo "💾 Disk Partitioning Guide:"
echo "=========================="
echo "For a single NVMe SSD with LUKS encryption:"
echo ""
echo "1. Create GPT partition table"
echo "2. Create EFI partition (512MB):"
echo "   - Type: EFI System Partition"
echo "   - Mount point: /boot"
echo ""
echo "3. Create LUKS partition (remaining space):"
echo "   - Type: Linux LVM"
echo "   - This will be encrypted"
echo ""
echo "4. Inside LUKS container, create BTRFS subvolumes:"
echo "   - @ (root)"
echo "   - @home (home)"
echo "   - @nix (nix store)"
echo "   - @log (logs)"
echo "   - @swap (swap)"
echo ""

# Get disk information
echo "🔍 Current disk information:"
lsblk
echo ""

# Ask for disk selection
read -p "Enter the disk to install to (e.g., /dev/nvme0n1): " DISK

if [ ! -b "$DISK" ]; then
    echo "❌ $DISK is not a valid block device"
    exit 1
fi

echo "⚠️  WARNING: This will completely wipe $DISK"
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "❌ Installation cancelled"
    exit 1
fi

# Partitioning script
echo "🔧 Creating partitions..."

# Create GPT partition table
parted "$DISK" --script mklabel gpt

# Create EFI partition
parted "$DISK" --script mkpart ESP fat32 1MiB 512MiB
parted "$DISK" --script set 1 esp on

# Create LUKS partition
parted "$DISK" --script mkpart primary 512MiB 100%

# Get partition paths
EFI_PART="${DISK}p1"
LUKS_PART="${DISK}p2"

echo "📝 Partitioning complete!"
echo "EFI partition: $EFI_PART"
echo "LUKS partition: $LUKS_PART"
echo ""

# Format EFI partition
echo "🔧 Formatting EFI partition..."
mkfs.fat -F 32 -n boot "$EFI_PART"

# Setup LUKS
echo "🔐 Setting up LUKS encryption..."
cryptsetup luksFormat "$LUKS_PART"
cryptsetup open "$LUKS_PART" cryptroot

# Create BTRFS filesystem
echo "🌳 Creating BTRFS filesystem..."
mkfs.btrfs -L nixos /dev/mapper/cryptroot

# Mount and create subvolumes
echo "📁 Creating BTRFS subvolumes..."
mount /dev/mapper/cryptroot /mnt

cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @nix
btrfs subvolume create @log
btrfs subvolume create @swap

# Unmount and remount with subvolumes
cd /
umount /mnt

mount -o subvol=@ /dev/mapper/cryptroot /mnt
mkdir -p /mnt/{boot,home,nix,var/log}
mount -o subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o subvol=@nix /dev/mapper/cryptroot /mnt/nix
mount -o subvol=@log /dev/mapper/cryptroot /mnt/var/log
mount "$EFI_PART" /mnt/boot

# Create swap file
echo "💾 Creating swap file..."
btrfs subvolume create /mnt/@swap
mount -o subvol=@swap /dev/mapper/cryptroot /mnt/swap
truncate -s 0 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
btrfs property set /mnt/swap/swapfile compression none
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count=16384 status=progress
chmod 600 /mnt/swap/swapfile
mkswap /mnt/swap/swapfile
swapon /mnt/swap/swapfile

# Get UUIDs
EFI_UUID=$(blkid -s UUID -o value "$EFI_PART")
LUKS_UUID=$(blkid -s UUID -o value "$LUKS_PART")
SWAP_UUID=$(blkid -s UUID -o value /mnt/swap/swapfile)

echo "📝 UUIDs:"
echo "EFI: $EFI_UUID"
echo "LUKS: $LUKS_UUID"
echo "Swap: $SWAP_UUID"
echo ""

# Update configuration files with UUIDs
echo "🔧 Updating configuration files with UUIDs..."

# Update disk-setup.nix
sed -i "s/YOUR_ROOT_UUID/$LUKS_UUID/g" system/disk-setup.nix
sed -i "s/YOUR_BOOT_UUID/$EFI_UUID/g" system/disk-setup.nix
sed -i "s/YOUR_SWAP_UUID/$SWAP_UUID/g" system/disk-setup.nix

# Update power-management.nix
sed -i "s/YOUR_SWAP_UUID/$SWAP_UUID/g" system/power-management.nix

# Update hardware.nix
sed -i "s/YOUR_SWAP_UUID/$SWAP_UUID/g" system/hardware.nix

echo "✅ Configuration files updated!"

# Generate hardware configuration
echo "🔧 Generating hardware configuration..."
nixos-generate-config --root /mnt

# Copy our configuration
echo "📋 Copying configuration files..."
cp -r . /mnt/etc/nixos/

# Install NixOS
echo "🚀 Installing NixOS..."
nixos-install --root /mnt --flake /mnt/etc/nixos#desktop

echo "✅ Installation complete!"
echo ""
echo "🎉 Next steps:"
echo "1. Reboot your system"
echo "2. Remove the USB drive"
echo "3. Your system should boot automatically into Hyprland"
echo "4. Run 'backup-config' to set up automated backups"
echo ""
echo "🔧 Post-installation:"
echo "1. Update your username in the configuration files"
echo "2. Set up SSH keys for GitHub backup"
echo "3. Configure your development environment"
echo ""
echo "📚 Useful commands:"
echo "- 'sudo nixos-rebuild switch --flake /etc/nixos#desktop' - Update system"
echo "- 'backup-config' - Manual backup"
echo "- 'mkpython <project>' - Create Python project with direnv"
echo "- 'mknode <project>' - Create Node.js project with direnv"
echo ""
echo "Happy coding! 🎯"