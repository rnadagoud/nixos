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
│   ├── laptop/
│   │   ├── configuration.nix
│   │   └── hardware-configuration.nix
│   └── desktop/
│       ├── configuration.nix
│       └── hardware-configuration.nix
├── modules/             # Reusable NixOS modules
│   ├── networking.nix
│   ├── users.nix
│   └── security.nix
├── home/                # Home Manager configs (optional)
│   └── default.nix
└── README.md


Structure may evolve as the setup grows.
