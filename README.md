# NixOS Development Workstation

A comprehensive NixOS configuration for a development workstation with Hyprland, automated backups, and proper version management.

## 🎯 Features

- **Hyprland** window manager with auto-login
- **LUKS encryption** with TPM disk unlocking
- **BTRFS** filesystem with subvolumes
- **Automated backups** to GitHub
- **Development environment** with proper version management
- **Hibernation** support
- **Hardware optimization** for Ryzen 3600 + 1660Ti + NVMe

## 🚀 Quick Start

1. **Boot from NixOS installer USB**
2. **Clone this repository:**
   ```bash
   git clone https://github.com/yourusername/nixos-config.git
   cd nixos-config
   ```
3. **Run the installation script:**
   ```bash
   ./install.sh
   ```
4. **Follow the prompts** to partition your disk and install

## 📋 Prerequisites

- NixOS installer USB
- Single NVMe SSD (recommended)
- TPM 2.0 support (for automatic disk unlocking)
- UEFI boot support

## 🔧 Configuration

### Before Installation

1. **Update personal information** in the configuration files:
   - `system/configuration.nix` - Change username, email, timezone
   - `home/home.nix` - Update user details
   - `system/backup.nix` - Set GitHub repository URL

2. **Review hardware settings** in `system/hardware.nix`

### After Installation

1. **Set up SSH keys for GitHub backup:**
   ```bash
   ssh-keygen -t ed25519 -C "nixos-config-backup"
   # Add the public key to your GitHub account
   ```

2. **Configure automated backups:**
   ```bash
   backup-config  # Manual backup
   ```

## 🛠️ Development Environment

### Per-Project Environments

This configuration solves your Python/Node version management issues from Arch:

```bash
# Create a Python project with automatic environment
mkpython my-project
cd my-project
direnv allow  # Activates the environment automatically

# Create a Node.js project
mknode my-app
cd my-app
direnv allow
```

### Available Languages

- **Python 3.11** with pip, poetry, pipenv
- **Node.js 20** with npm, yarn, pnpm
- **Go** with gopls
- **Rust** with rust-analyzer
- **Java 17** with JDT language server
- **.NET 8** SDK

### Development Tools

- **Neovim** with basic configuration
- **VS Code** with essential extensions
- **Docker & Podman** with compose support
- **Git** with useful aliases
- **Direnv** for automatic environment activation

## 🎨 Hyprland Configuration

### Key Bindings

- `Super + Q` - Open terminal
- `Super + C` - Close window
- `Super + M` - Exit Hyprland
- `Super + E` - Open file manager
- `Super + R` - Open application launcher
- `Super + V` - Toggle floating window
- `Super + 1-9` - Switch workspaces
- `Super + Shift + 1-9` - Move window to workspace

### Customization

Edit `home/home.nix` to customize:
- Key bindings
- Window rules
- Appearance
- Applications

## 🔐 Security Features

- **LUKS encryption** for all data
- **TPM 2.0** automatic disk unlocking
- **Secure boot** support
- **SSH key-based** authentication
- **Firewall** configuration
- **Automatic security updates**

## 💾 Backup System

### Automated Backups

- **Weekly automatic backups** to GitHub
- **Configuration files** backup
- **User dotfiles** backup
- **System information** tracking

### Manual Backup

```bash
backup-config  # Manual backup
```

### Backup Contents

- System configuration files
- Home Manager configuration
- User dotfiles (Neovim, Hyprland, etc.)
- System information and status

## ⚡ Power Management

### Hibernation

- **Automatic hibernation** on low battery
- **Lid close** triggers hibernation
- **30-minute idle** timeout
- **Swap file** for hibernation support

### Performance

- **Performance mode** for desktop use
- **NVIDIA GPU** power management
- **CPU frequency scaling**
- **NVMe optimization**

## 🔧 Maintenance

### System Updates

```bash
# Update system
sudo nixos-rebuild switch --flake /etc/nixos#desktop

# Update and rebuild
sudo nixos-rebuild switch --upgrade --flake /etc/nixos#desktop
```

### Garbage Collection

```bash
# Clean up old generations
sudo nix-collect-garbage -d

# Clean up store
sudo nix-store --optimise
```

### Rollback

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

## 📁 Directory Structure

```
├── flake.nix                 # Main flake configuration
├── install.sh               # Installation script
├── README.md                # This file
├── system/                  # System configuration
│   ├── configuration.nix    # Main system config
│   ├── hardware.nix         # Hardware-specific settings
│   ├── disk-setup.nix       # LUKS and filesystem config
│   ├── hyprland.nix         # Hyprland configuration
│   ├── backup.nix           # Backup system
│   └── power-management.nix # Power and hibernation
└── home/                    # Home Manager configuration
    ├── home.nix             # Main home config
    └── dev-environment.nix  # Development environment
```

## 🐛 Troubleshooting

### Common Issues

1. **Boot issues:**
   - Check UEFI settings
   - Verify secure boot configuration
   - Check TPM settings

2. **Hyprland not starting:**
   - Check logs: `journalctl -u display-manager`
   - Verify graphics drivers
   - Check Wayland session

3. **Backup failures:**
   - Verify SSH keys
   - Check GitHub repository access
   - Review backup logs

4. **Development environment:**
   - Run `direnv allow` in project directories
   - Check `.envrc` files
   - Verify language servers

### Getting Help

- Check system logs: `journalctl -xe`
- Review configuration files
- Test with minimal configuration
- Check NixOS documentation

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager](https://nix-community.github.io/home-manager/)
- [Hyprland](https://hyprland.org/)
- [Direnv](https://direnv.net/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the configuration
5. Submit a pull request

## 📄 License

This configuration is provided as-is for educational and personal use.

---

**Happy coding! 🎯**

*This configuration solves the common pain points from Arch Linux, especially Python/Node version management, by using NixOS's declarative approach and direnv for per-project environments.*