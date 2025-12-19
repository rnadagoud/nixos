# NixOS Configuration

Personal NixOS configuration repository using flakes.

This repo will contain system, user, and host-specific configurations for NixOS machines, with a focus on reproducibility, clarity, and easy onboarding.

---

## Goals

- Declarative, reproducible NixOS systems
- Flake-based setup
- Clear separation of concerns (system, users, hosts)
- Easy rebuilds and upgrades
- Minimal but well-documented configuration

---

## Planned Structure

```text
.
├── flake.nix            # Entry point (systems, inputs, outputs)
├── flake.lock           # Locked dependencies
├── hosts/               # Host-specific configurations
│   └── desktop/
│       ├── configuration.nix
│       ├── hardware-configuration.nix
│       └── disko.nix
├── modules/             # Reusable NixOS modules
│   ├── core/
│   │   ├── default.nix
│   │   ├── boot.nix
│   │   ├── fonts.nix
│   │   ├── network.nix
│   │   ├── nix.nix
│   │   └── security.nix
│   ├── desktop/
│   │   ├── hyprland.nix
│   │   └── niri.nix
│   ├── hardware/
│   │   ├── bluetooth.nix
│   │   ├── nvidia.nix
│   │   ├── pipewire.nix
│   │   └── ssd.nix
│   └── programs/
│       ├── git.nix
│       └── virt-manager.nix
├── home/                # Home Manager configs (optional)
│   └── default.nix
└── README.md


Structure may evolve as the setup grows.

---

## This repository (current state)

- Flake-based NixOS config with a primary host `nixos-btw` (desktop). The flake uses `nixpkgs` pinned to **nixos-25.11** and includes inputs such as `home-manager`, `disko`, and `nixos-hardware`.
- Host configuration lives under `hosts/desktop/` and is intentionally scaffolded with placeholders for disk partitions and swap. See `hosts/desktop/hardware-configuration.nix` and `hosts/desktop/disko.nix`.
- Most `modules/` are implemented as small, composable modules (core boot, network, security, fonts, desktop, hardware helpers, etc.).

## Quickstart (deploying the desktop host) ⚙️

1. Inspect and adjust partitioning in `hosts/desktop/disko.nix` and `hosts/desktop/hardware-configuration.nix` to match your actual device (e.g., `/dev/nvme0n1`).
2. Ensure your user password is set after installation — this repo leaves the `rahul` password intentionally unset and contains a TODO comment in `hosts/desktop/configuration.nix` where you may add a hashed password.
3. Build and switch the configuration on the machine (example):

```bash
# from repo root
nix build .#nixosConfigurations.nixos-btw.config.system.build.toplevel
sudo /nix/var/nix/profiles/system/default/bin/switch-to-configuration switch
```

Or with flakes (if `nixos-rebuild` supports flakes on your system):

```bash
# run on the target machine
nixos-rebuild switch --flake .#nixos-btw
```

> Note: This repository leaves intentional placeholders (password, exact partition device names). Double-check those before running destructive commands.

## Packages & Services included 

- System packages: firefox, kitty, vscode, git, vim, amd-ucode and utilities like `ripgrep`, `fd`, `bat`, `btop`, `ncdu`, `curl`, `unzip`, `pciutils`, `usbutils`, `zoxide`, `fastfetch`, `eza`, `nix-tree`, `alejandra`.
- Services enabled: NetworkManager, GDM (Wayland), Hyprland, PipeWire, BlueZ, Docker, libvirtd, SSH (port 2222, password auth disabled), fail2ban, and systemd-boot (UEFI).

## Security & policy notes 

- SSH is configured to listen on **port 2222** with password authentication disabled. Add your public SSH keys to `users.users.<name>.openssh.authorizedKeys.keys` or via Home Manager.
- Nix settings include `auto-optimise-store` and a hint to use `cache.nix-community` as a substituter; add trusted keys if you enable external caches.

## License

This repo is licensed under **MIT**. See `LICENSE` 
