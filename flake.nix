# flake.nix
{
  description = "NixOS 25.05 secure Wayland desktop (Hyprland + NVIDIA) with Btrfs, Snapper, TPM2, Flatpak, Steam, direnv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";
  };

  outputs = { self, nixpkgs, home-manager, lanzaboote, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    nixosConfigurations.HOSTNAME = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./hardware-configuration.nix

          # Lanzaboote Secure Boot + systemd initrd + TPM2
        lanzaboote.nixosModules.lanzaboote
        ({ lib, pkgs, ... }: {
          boot.loader.systemd-boot.enable = lib.mkForce false;
          boot.lanzaboote = {
            enable = true;
            pkiBundle = "/etc/secureboot";
          };
          boot.initrd.systemd.enable = true;
          boot.initrd.systemd.tpm2.enable = true;
          security.tpm2.enable = true;
          boot.loader.efi.canTouchEfiVariables = true;
          boot.loader.efi.efiSysMountPoint = "/boot/efi";
        })

        # Base system
        ({ config, lib, pkgs, ... }: {
          networking.hostName = "HOSTNAME";
          time.timeZone = "Asia/Kolkata";
          i18n.defaultLocale = "en_US.UTF-8";
          i18n.extraLocaleSettings.LC_TIME = "en_US.UTF-8";

          # Btrfs + hibernation-friendly swapfile path (create post-install)
          services.fstrim.enable = true;

          # LUKS root with TPM2 auto-unlock (fill UUID and name as created during install)
          boot.initrd.luks.devices.cryptroot = {
            device = "/dev/disk/by-uuid/UUID-OF-LUKS-PV";
            crypttabExtraOpts = [ "tpm2-device=auto" "tpm2-try-fallback=yes" ];
          };

          # Swap device (size set during install; no resume params needed with systemd initrd)
          swapDevices = [ { device = "/dev/disk/by-uuid/SWAP-UUID"; } ];

          # NVIDIA + Wayland
          services.xserver.enable = false;
          hardware.opengl.enable = true;
          hardware.opengl.driSupport = true;
          hardware.opengl.driSupport32Bit = true;
          services.xserver.videoDrivers = [ "nvidia" ];
          hardware.nvidia = {
            modesetting.enable = true;
            powerManagement.enable = true;
            open = false;
          };
          boot.kernelParams = [
            "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
          ];

          # Hyprland + portals + PipeWire
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

          # Steam + Gamescope
          programs.steam = {
            enable = true;
            gamescopeSession.enable = true;
          };
          programs.gamescope.enable = true;

          # Flatpak
          services.flatpak.enable = true;

          # Encrypted DNS (DoT) to Cloudflare via systemd-resolved
          services.resolved = {
            enable = true;
            dnsOverTls = "opportunistic";
            fallbackDns = [ "1.1.1.1#cloudflare-dns.com" "1.0.0.1#cloudflare-dns.com" ];
          };
          networking.networkmanager.enable = true;

          # Containers / virtualization
          virtualisation = {
            docker.enable = true;
            podman.enable = true;
          };

          # SSH hardening (optional server role)
          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = false;
            settings.KbdInteractiveAuthentication = false;
            settings.PermitRootLogin = "no";
          };

          # User + HM
          users.users.USERNAME = {
            isNormalUser = true;
            extraGroups = [ "wheel" "networkmanager" "video" "audio" "docker" ];
            shell = pkgs.fish;
          };

          # Auto updates (system)
          system.autoUpgrade = {
            enable = true;
            flake = self.outPath;
            dates = "daily";
            randomizedDelaySec = "45min";
          };

          environment.systemPackages = with pkgs; [
            git vim wget curl kitty alacritty
            wl-clipboard
          ];

          # Nix tweaks for dev
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          system.stateVersion = "25.05";
        })

        # Home Manager: fish, editors, terminals, direnv, basic desktop apps
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.USERNAME = { pkgs, ... }: {
            home.stateVersion = "25.05";
            programs = {
              fish = {
                enable = true;
                shellInit = ''
                  # Fish shell initialization
                '';
              };
              neovim.enable = true;
              vscode.enable = true;
              direnv = {
                enable = true;
                nix-direnv.enable = true;
              };
            };
            home.packages = with pkgs; [
              # user-level utilities
              kitty alacritty
            ];
          };
        }
      ];
    };
  };
}
