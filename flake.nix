{
  description = "NixOS 25.05 secure Wayland desktop (Hyprland + NVIDIA) with Btrfs, Snapper, TPM2, Flatpak, Steam, direnv, DoT";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.HOSTNAME = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hardware-configuration.nix

        lanzaboote.nixosModules.lanzaboote
        ({ lib, pkgs, ... }: {
          # Secure Boot via Lanzaboote + systemd initrd + TPM2
          boot.loader.systemd-boot.enable = lib.mkForce false;
          boot.loader.efi.canTouchEfiVariables = true;

          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/var/lib/sbctl";  # sbctl's current default
          };

          boot.initrd.systemd.enable = true;
          boot.initrd.systemd.tpm2.enable = true;
          security.tpm2.enable = true;

          # Nix features for the installed system
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          # Host basics
          networking.hostName = "HOSTNAME";
          time.timeZone = "Asia/Kolkata";

          # Locales (supported and correct formatting)
          i18n.defaultLocale = "en_US.UTF-8";
          i18n.supportedLocales = [
            "en_US.UTF-8/UTF-8"
            "en_GB.UTF-8/UTF-8"
          ];
          i18n.extraLocaleSettings.LC_TIME = "en_GB.UTF-8";
          system.stateVersion = "25.05";

          # Filesystems and trim
          services.fstrim.enable = true;

          # Encrypted root (fill UUID)
          boot.initrd.luks.devices.cryptroot = {
            device = "/dev/disk/by-uuid/UUID-OF-LUKS-PV";
            crypttabExtraOpts = [ "tpm2-device=auto" "tpm2-try-fallback=yes" ];
          };

          # Swapfile on Btrfs (already created NOCOW)
          swapDevices = [ { device = "/swap/swapfile"; } ];

          # Graphics: modern interface (replaces hardware.opengl)
          hardware.graphics = {
            enable = true;
            enable32Bit = true;
          };

          # NVIDIA + Wayland
          services.xserver.enable = false;
          services.xserver.videoDrivers = [ "nvidia" ];
          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = true;
            open = false;
          };
          boot.kernelParams = [
            "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
          ];

          # Hyprland + portals + audio
          programs.hyprland.enable = true;
          xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
              xdg-desktop-portal-hyprland
              xdg-desktop-portal-gtk
            ];
          };
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            pulse.enable = true;
            wireplumber.enable = true;
          };

          # Gaming
          programs.steam = {
            enable = true;
            gamescopeSession.enable = true;
          };
          programs.gamescope.enable = true;

          # Flatpak
          services.flatpak.enable = true;

          # Cloudflare DNS over TLS via systemd-resolved
          services.resolved = {
            enable = true;
            dnsovertls = "opportunistic";
            fallbackDns = [
              "1.1.1.1#cloudflare-dns.com"
              "1.0.0.1#cloudflare-dns.com"
            ];
          };
          networking.networkmanager.enable = true;

          # Containers
          virtualisation = {
            docker.enable = true;
            podman.enable = true;
          };

          # SSH
          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = false;
            settings.KbdInteractiveAuthentication = false;
            settings.PermitRootLogin = "no";
          };

          # User and shells
          nixpkgs.config.allowUnfree = true;
          users.users.USERNAME = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
            shell = pkgs.fish;
          };
          programs.fish.enable = true;

          # Auto updates (system)
          system.autoUpgrade = {
            enable = true;
            flake = self.outPath;
            dates = "daily";
            randomizedDelaySec = "45min";
          };

          environment.systemPackages = with pkgs; [
            git vim wget curl
            wl-clipboard
            kitty alacritty
          ];
        })

        # Snapper policies (root + home)
        ({ config, lib, pkgs, ... }: {
          services.snapper = {
            snapshotRootOnBoot = true;
            configs = {
              root = {
                SUBVOLUME = "/";
                ALLOW_USERS = [ "root" ];
                TIMELINE_CREATE = true;
                TIMELINE_CLEANUP = true;
                TIMELINE_MIN_AGE = "1800";
                TIMELINE_LIMIT_HOURLY = 12;
                TIMELINE_LIMIT_DAILY = 7;
                TIMELINE_LIMIT_WEEKLY = 4;
                TIMELINE_LIMIT_MONTHLY = 3;
                TIMELINE_LIMIT_YEARLY = 0;
              };
              home = {
                SUBVOLUME = "/home";
                ALLOW_USERS = [ "USERNAME" ];
                TIMELINE_CREATE = true;
                TIMELINE_CLEANUP = true;
              };
            };
          };
        })

        # Home Manager: editors, terminals, direnv
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.USERNAME = { pkgs, ... }: {
            home.stateVersion = "25.05";
            programs = {
              fish.enable = true;
              neovim.enable = true;
              vscode.enable = true;
              direnv = {
                enable = true;
                nix-direnv.enable = true;
              };
            };
            home.packages = with pkgs; [
              kitty alacritty
            ];
          };
        }
      ];
    };
  };
}