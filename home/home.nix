{ config, pkgs, inputs, ... }:

{
  # Home Manager configuration
  home.username = "user"; # Change this to your username
  home.homeDirectory = "/home/user"; # Change this to your home directory
  home.stateVersion = "23.11";
  
  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
  
  # Essential packages
  home.packages = with pkgs; [
    # Development tools
    direnv
    nix-direnv
    git
    gh
    lazygit
    
    # Languages and runtimes
    nodejs_20
    python311
    python311Packages.pip
    python311Packages.virtualenv
    go
    rustc
    cargo
    jdk17
    dotnet-sdk_8
    
    # Container tools
    docker-compose
    podman-compose
    buildah
    skopeo
    
    # System utilities
    htop
    btop
    neofetch
    tree
    ripgrep
    fd
    bat
    exa
    fzf
    jq
    yq
    
    # Media
    vlc
    spotify
    
    # Office
    libreoffice
    
    # Gaming
    steam
    heroic
    
    # Browsers
    ungoogled-chromium
    
    # Editors
    neovim
    vscode
    
    # Hyprland tools
    hyprpaper
    waybar
    rofi-wayland
    wl-clipboard
    grim
    slurp
  ];
  
  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ll = "exa -l";
      la = "exa -la";
      tree = "exa --tree";
      cat = "bat";
      grep = "rg";
      find = "fd";
      ps = "btop";
      top = "btop";
    };
    
    initExtra = ''
      # Direnv hook
      eval "$(direnv hook zsh)"
      
      # Nix-direnv
      source ${pkgs.nix-direnv}/share/nix-direnv/direnvrc
      
      # FZF configuration
      export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
      export FZF_DEFAULT_COMMAND="fd --type f"
      
      # Development environment
      export EDITOR="nvim"
      export BROWSER="ungoogled-chromium"
    '';
  };
  
  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name"; # Change this
    userEmail = "your.email@example.com"; # Change this
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
  
  # Neovim configuration
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };
  
  # VS Code configuration
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      ms-vscode.vscode-json
      ms-python.python
      ms-vscode.vscode-typescript-next
      bradlc.vscode-tailwindcss
      esbenp.prettier-vscode
      ms-vscode.vscode-eslint
    ];
  };
  
  # Direnv configuration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  
  # Hyprland configuration
  xdg.configFile."hypr/hyprland.conf".text = ''
    # Hyprland configuration
    monitor=,preferred,auto,1
    
    # Input configuration
    input {
        kb_layout = us
        kb_variant =
        kb_model =
        kb_options =
        kb_rules =
        follow_mouse = 1
        touchpad {
            natural_scroll = no
        }
        sensitivity = 0
    }
    
    # General configuration
    general {
        gaps_in = 5
        gaps_out = 20
        border_size = 2
        col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
        col.inactive_border = rgba(595959aa)
        layout = dwindle
    }
    
    # Decoration
    decoration {
        rounding = 10
        blur {
            enabled = true
            size = 3
            passes = 1
        }
        drop_shadow = yes
        shadow_range = 4
        shadow_render_power = 3
        col.shadow = rgba(1a1a1aee)
    }
    
    # Animations
    animations {
        enabled = yes
        bezier = myBezier, 0.05, 0.9, 0.1, 1.05
        animation = windows, 1, 7, myBezier
        animation = windowsOut, 1, 7, default, popin 80%
        animation = border, 1, 10, default
        animation = borderangle, 1, 8, default
        animation = fade, 1, 7, default
        animation = workspaces, 1, 6, default
    }
    
    # Dwindle layout
    dwindle {
        pseudotile = yes
        preserve_split = yes
    }
    
    # Key bindings
    bind = SUPER, Q, exec, kitty
    bind = SUPER, C, killactive,
    bind = SUPER, M, exit,
    bind = SUPER, E, exec, dolphin
    bind = SUPER, V, togglefloating,
    bind = SUPER, R, exec, rofi -show drun
    bind = SUPER, P, pseudo,
    bind = SUPER, J, togglesplit,
    
    # Move focus
    bind = SUPER, left, movefocus, l
    bind = SUPER, right, movefocus, r
    bind = SUPER, up, movefocus, u
    bind = SUPER, down, movefocus, d
    
    # Switch workspaces
    bind = SUPER, 1, workspace, 1
    bind = SUPER, 2, workspace, 2
    bind = SUPER, 3, workspace, 3
    bind = SUPER, 4, workspace, 4
    bind = SUPER, 5, workspace, 5
    bind = SUPER, 6, workspace, 6
    bind = SUPER, 7, workspace, 7
    bind = SUPER, 8, workspace, 8
    bind = SUPER, 9, workspace, 9
    bind = SUPER, 0, workspace, 10
    
    # Move active window to workspace
    bind = SUPER SHIFT, 1, movetoworkspace, 1
    bind = SUPER SHIFT, 2, movetoworkspace, 2
    bind = SUPER SHIFT, 3, movetoworkspace, 3
    bind = SUPER SHIFT, 4, movetoworkspace, 4
    bind = SUPER SHIFT, 5, movetoworkspace, 5
    bind = SUPER SHIFT, 6, movetoworkspace, 6
    bind = SUPER SHIFT, 7, movetoworkspace, 7
    bind = SUPER SHIFT, 8, movetoworkspace, 8
    bind = SUPER SHIFT, 9, movetoworkspace, 9
    bind = SUPER SHIFT, 0, movetoworkspace, 10
    
    # Scroll through existing workspaces
    bind = SUPER, mouse_down, workspace, e+1
    bind = SUPER, mouse_up, workspace, e-1
    
    # Move/resize windows
    bindm = SUPER, mouse:272, movewindow
    bindm = SUPER, mouse:273, resizewindow
  '';
  
  # Waybar configuration
  xdg.configFile."waybar/config".text = ''
    {
        "layer": "top",
        "position": "top",
        "height": 30,
        "spacing": 4,
        "modules-left": ["hyprland/workspaces"],
        "modules-center": ["hyprland/window"],
        "modules-right": ["network", "pulseaudio", "battery", "clock"],
        "hyprland/workspaces": {
            "disable-scroll": true,
            "all-outputs": true,
            "format": "{icon}",
            "format-icons": {
                "1": "",
                "2": "",
                "3": "",
                "4": "",
                "5": "",
                "urgent": "",
                "focused": "",
                "default": ""
            }
        },
        "hyprland/window": {
            "format": "{}",
            "separate-outputs": true
        },
        "network": {
            "format-wifi": "{essid} ({signalStrength}%)",
            "format-ethernet": "{ipaddr}/{cidr}",
            "tooltip-format": "{ifname} via {gwaddr}",
            "format-linked": "{ifname} (No IP)",
            "format-disconnected": "Disconnected ⚠",
            "format-alt": "{ifname}: {ipaddr}/{cidr}"
        },
        "pulseaudio": {
            "format": "{volume}% {icon} {format_source}",
            "format-bluetooth": "{volume}% {icon} {format_source}",
            "format-bluetooth-muted": " {icon} {format_source}",
            "format-muted": " {format_source}",
            "format-source": "{volume}% ",
            "format-source-muted": "",
            "format-icons": {
                "headphone": "",
                "hands-free": "",
                "headset": "",
                "phone": "",
                "portable": "",
                "car": "",
                "default": ["", "", ""]
            },
            "on-click": "pavucontrol"
        },
        "battery": {
            "states": {
                "warning": 30,
                "critical": 15
            },
            "format": "{capacity}% {icon}",
            "format-charging": "{capacity}% ",
            "format-plugged": "{capacity}% ",
            "format-alt": "{time} {icon}",
            "format-icons": ["", "", "", "", ""]
        },
        "clock": {
            "format": "{:%Y-%m-%d %H:%M}",
            "tooltip-format": "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>"
        }
    }
  '';
  
  # Waybar style
  xdg.configFile."waybar/style.css".text = ''
    * {
        border: none;
        border-radius: 0;
        font-family: "JetBrainsMono Nerd Font", "Font Awesome 6 Free";
        font-size: 13px;
        min-height: 0;
    }
    
    window#waybar {
        background: #1e1e2e;
        color: #cdd6f4;
    }
    
    tooltip {
        background: #1e1e2e;
        border: 1px solid #11111b;
        border-radius: 10px;
    }
    
    #workspaces button {
        padding: 0 5px;
        background: transparent;
        color: #cdd6f4;
        border-bottom: 3px solid transparent;
    }
    
    #workspaces button.focused {
        background: #313244;
        border-bottom: 3px solid #cba6f7;
    }
    
    #workspaces button.urgent {
        color: #f38ba8;
    }
    
    #mode {
        background: #f38ba8;
        border-bottom: 3px solid #cdd6f4;
    }
    
    #clock, #battery, #cpu, #memory, #network, #pulseaudio, #tray, #mode {
        padding: 0 10px;
        margin: 0 5px;
    }
    
    #clock {
        background-color: #313244;
    }
    
    #battery {
        background-color: #313244;
    }
    
    #battery.charging {
        color: #a6e3a1;
    }
    
    @keyframes blink {
        to {
            background-color: #f38ba8;
            color: #1e1e2e;
        }
    }
    
    #battery.critical:not(.charging) {
        background: #f38ba8;
        color: #1e1e2e;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
    }
    
    #cpu {
        background: #313244;
    }
    
    #memory {
        background: #313244;
    }
    
    #network {
        background: #313244;
    }
    
    #network.disconnected {
        background: #f38ba8;
    }
    
    #pulseaudio {
        background: #313244;
    }
    
    #pulseaudio.muted {
        background: #313244;
    }
    
    #tray {
        background-color: #313244;
    }
  '';
}