{ config, pkgs, inputs, ... }:

let
  username = "user"; # Change this to your username
in
{
  # Basic system configuration
  system.stateVersion = "23.11";
  
  # Network configuration
  networking.hostName = "desktop";
  networking.networkmanager.enable = true;
  
  # Time zone and locale
  time.timeZone = "America/New_York"; # Change to your timezone
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  
  # User configuration
  users.users.${username} = {
    isNormalUser = true;
    description = "Main User";
    extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "audio" "video" "input" ];
    shell = pkgs.zsh;
  };
  
  # Enable automatic login to Hyprland
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = username;
  };
  
  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  
  # Enable Docker and Podman
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
  
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };
  
  # Development tools
  programs.git = {
    enable = true;
    config = {
      user.name = "Your Name"; # Change this
      user.email = "your.email@example.com"; # Change this
      init.defaultBranch = "main";
    };
  };
  
  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };
  
  # Essential system packages
  environment.systemPackages = with pkgs; [
    # System utilities
    wget
    curl
    git
    htop
    tree
    unzip
    zip
    file
    which
    jq
    ripgrep
    fd
    bat
    exa
    fzf
    
    # Development tools
    direnv
    nix-direnv
    
    # Media
    vlc
    spotify
    
    # Office
    libreoffice
    
    # Gaming
    steam
    heroic
    
    # Browsers
    ungoogled-chromium # Zen browser alternative
    
    # Editors
    neovim
    vscode
    
    # Container tools
    docker-compose
    podman-compose
  ];
  
  # Enable flakes and nix command
  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
    settings = {
      auto-optimise-store = true;
      trusted-users = [ "root" username ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  
  # Security
  security.sudo.wheelNeedsPassword = false;
  
  # Power management
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;
  
  # Audio
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  
  # Fonts
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    dina-font
    proggyfonts
  ];
  
  # XDG Desktop Portal
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
  
  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}