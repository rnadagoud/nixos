{ config, pkgs, ... }:

{
  # Automated backup system for configuration files
  
  # Create backup script
  systemd.services.config-backup = {
    description = "Backup NixOS configuration to GitHub";
    serviceConfig = {
      Type = "oneshot";
      User = "user"; # Change to your username
      ExecStart = pkgs.writeShellScript "backup-config" ''
        set -euo pipefail
        
        # Configuration
        BACKUP_DIR="/home/user/.config-backup"
        REPO_URL="https://github.com/yourusername/nixos-config.git" # Change this
        BRANCH="main"
        
        # Create backup directory if it doesn't exist
        mkdir -p "$BACKUP_DIR"
        
        # Initialize git repo if it doesn't exist
        if [ ! -d "$BACKUP_DIR/.git" ]; then
          cd "$BACKUP_DIR"
          git init
          git remote add origin "$REPO_URL"
          git checkout -b "$BRANCH"
        fi
        
        # Copy configuration files
        cd "$BACKUP_DIR"
        
        # System configuration
        mkdir -p system
        cp -r /workspace/system/* system/ 2>/dev/null || true
        
        # Home configuration
        mkdir -p home
        cp -r /workspace/home/* home/ 2>/dev/null || true
        
        # Flake configuration
        cp /workspace/flake.nix . 2>/dev/null || true
        
        # User dotfiles
        mkdir -p dotfiles
        cp -r /home/user/.config/nvim dotfiles/ 2>/dev/null || true
        cp -r /home/user/.config/hypr dotfiles/ 2>/dev/null || true
        cp -r /home/user/.config/waybar dotfiles/ 2>/dev/null || true
        cp /home/user/.zshrc dotfiles/ 2>/dev/null || true
        cp /home/user/.gitconfig dotfiles/ 2>/dev/null || true
        
        # Create backup info
        cat > backup-info.txt << EOF
        Backup created: $(date)
        Hostname: $(hostname)
        NixOS version: $(nixos-version)
        Kernel: $(uname -r)
        Uptime: $(uptime -p)
        EOF
        
        # Git operations
        git add .
        git commit -m "Automated backup: $(date)" || true
        git push origin "$BRANCH" || true
        
        echo "Configuration backup completed successfully"
      '';
    };
  };
  
  # Schedule backup to run weekly
  systemd.timers.config-backup = {
    description = "Weekly configuration backup timer";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
  
  # Enable the timer
  systemd.timers.config-backup.enable = true;
  
  # Manual backup script for user
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "backup-config" ''
      #!/bin/bash
      set -euo pipefail
      
      echo "Starting manual configuration backup..."
      sudo systemctl start config-backup.service
      echo "Backup completed!"
    '')
  ];
  
  # Git configuration for backup
  programs.git = {
    enable = true;
    config = {
      user.name = "Your Name"; # Change this
      user.email = "your.email@example.com"; # Change this
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
    };
  };
  
  # SSH configuration for GitHub access
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };
  
  # Create SSH key for GitHub if it doesn't exist
  systemd.services.setup-github-ssh = {
    description = "Setup SSH key for GitHub";
    serviceConfig = {
      Type = "oneshot";
      User = "user"; # Change to your username
      ExecStart = pkgs.writeShellScript "setup-github-ssh" ''
        set -euo pipefail
        
        SSH_DIR="/home/user/.ssh"
        SSH_KEY="$SSH_DIR/id_ed25519"
        
        # Create SSH directory if it doesn't exist
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
        
        # Generate SSH key if it doesn't exist
        if [ ! -f "$SSH_KEY" ]; then
          ssh-keygen -t ed25519 -f "$SSH_KEY" -N "" -C "nixos-config-backup"
          chmod 600 "$SSH_KEY"
          chmod 644 "$SSH_KEY.pub"
          
          echo "SSH key generated: $SSH_KEY.pub"
          echo "Add this public key to your GitHub account:"
          cat "$SSH_KEY.pub"
        fi
        
        # Add GitHub to known hosts
        ssh-keyscan -H github.com >> "$SSH_DIR/known_hosts" 2>/dev/null || true
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };
}