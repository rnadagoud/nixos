{ config, pkgs, inputs, ... }:

{
  # Hyprland configuration
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };
  
  # XDG Desktop Portal for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config.common.default = "hyprland";
  };
  
  # Display manager configuration for auto-login
  services.xserver.displayManager = {
    defaultSession = "hyprland";
    sessionPackages = [ inputs.hyprland.packages.${pkgs.system}.hyprland ];
  };
  
  # Enable wayland session
  programs.waybar.enable = true;
  
  # Hyprland-specific packages
  environment.systemPackages = with pkgs; [
    # Hyprland essentials
    hyprpaper
    hypridle
    hyprlock
    wl-clipboard
    grim
    slurp
    wf-recorder
    
    # Wayland utilities
    waybar
    rofi-wayland
    swww
    eww-wayland
    
    # Input method
    fcitx5
    fcitx5-configtool
    fcitx5-gtk
    fcitx5-qt
  ];
  
  # Font configuration for Hyprland
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" "JetBrainsMono" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
  ];
  
  # Input method configuration
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-chinese-addons
      fcitx5-gtk
      fcitx5-qt
    ];
  };
  
  # Environment variables for Hyprland
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    CLUTTER_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
}