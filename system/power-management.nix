{ config, pkgs, ... }:

{
  # Power management and hibernation configuration
  
  # Enable power management
  powerManagement.enable = true;
  powerManagement.cpuFreqGovernor = "performance"; # Change to "powersave" for laptops
  
  # Hibernation configuration
  boot.kernelParams = [
    "resume=UUID=YOUR_SWAP_UUID" # Replace with actual swap UUID
    "resume_offset=0"
  ];
  
  # Swap configuration for hibernation
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/YOUR_SWAP_UUID"; # Replace with actual UUID
      randomEncryption = true;
    }
  ];
  
  # Systemd logind configuration for hibernation
  services.logind = {
    extraConfig = ''
      HandleSuspendKey=hibernate
      HandleLidSwitch=hibernate
      HandleLidSwitchExternalPower=hibernate
      HandleLidSwitchDocked=ignore
      IdleAction=hibernate
      IdleActionSec=30min
    '';
  };
  
  # Power profiles daemon
  services.power-profiles-daemon.enable = true;
  
  # TLP for power management (alternative to power-profiles-daemon)
  services.tlp = {
    enable = false; # Disable if using power-profiles-daemon
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_SCALING_MIN_FREQ_ON_AC = 0;
      CPU_SCALING_MAX_FREQ_ON_AC = 0;
      CPU_SCALING_MIN_FREQ_ON_BAT = 0;
      CPU_SCALING_MAX_FREQ_ON_BAT = 0;
      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      SCHED_POWERSAVE_ON_AC = 0;
      SCHED_POWERSAVE_ON_BAT = 1;
      NMI_WATCHDOG = 0;
      DISK_DEVICES = "nvme0n1";
      DISK_APM_LEVEL_ON_AC = "254 254";
      DISK_APM_LEVEL_ON_BAT = "128 128";
      DISK_SPINDOWN_TIMEOUT_ON_AC = "0 0";
      DISK_SPINDOWN_TIMEOUT_ON_BAT = "0 0";
      DISK_IOSCHED = "mq-deadline mq-deadline";
      SATA_LINKPWR_ON_AC = "max_performance";
      SATA_LINKPWR_ON_BAT = "min_power";
      AHCI_RUNTIME_PM_ON_AC = "on";
      AHCI_RUNTIME_PM_ON_BAT = "auto";
      PCIE_ASPM_ON_AC = "performance";
      PCIE_ASPM_ON_BAT = "powersave";
      RADEON_POWER_PROFILE_ON_AC = "high";
      RADEON_POWER_PROFILE_ON_BAT = "low";
      RADEON_DPM_STATE_ON_AC = "performance";
      RADEON_DPM_STATE_ON_BAT = "battery";
      WIFI_PWR_ON_AC = "on";
      WIFI_PWR_ON_BAT = "on";
      WOL_DISABLE = "Y";
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 1;
      SOUND_POWER_SAVE_CONTROLLER = "Y";
      BAY_POWEROFF_ON_AC = 0;
      BAY_POWEROFF_ON_BAT = 0;
      BAY_DEVICE = "sr0";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
      USB_AUTOSUSPEND = 1;
      USB_BLACKLIST_WWAN = 1;
      USB_BLACKLIST_BTUSB = 0;
      USB_BLACKLIST_PHONE = 0;
      USB_BLACKLIST_PRINTER = 1;
      USB_BLACKLIST_UAS = 0;
      RESTORE_DEVICE_STATE_ON_STARTUP = 0;
    };
  };
  
  # CPU frequency scaling
  hardware.cpu.amd.updateMicrocode = true;
  
  # Kernel parameters for power management
  boot.kernelParams = config.boot.kernelParams ++ [
    # Power management
    "processor.max_cstate=1"
    "idle=nomwait"
    "amd_iommu=on"
    "iommu=pt"
    # Hibernation
    "resume=UUID=YOUR_SWAP_UUID"
    "resume_offset=0"
  ];
  
  # Systemd services for power management
  systemd.services.hibernate-on-low-battery = {
    description = "Hibernate on low battery";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "hibernate-on-low-battery" ''
        #!/bin/bash
        set -euo pipefail
        
        # Check if battery level is below 5%
        if command -v upower >/dev/null 2>&1; then
          BATTERY_LEVEL=$(upower -i $(upower -e | grep 'BAT') | grep -E "percentage" | awk '{print $2}' | sed 's/%//')
          if [ "$BATTERY_LEVEL" -lt 5 ]; then
            echo "Battery level is $BATTERY_LEVEL%, hibernating..."
            systemctl hibernate
          fi
        fi
      '';
    };
  };
  
  # Timer for low battery check
  systemd.timers.hibernate-on-low-battery = {
    description = "Check battery level every minute";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:*:00";
      Persistent = true;
    };
  };
  
  # Enable the timer
  systemd.timers.hibernate-on-low-battery.enable = true;
  
  # Power management utilities
  environment.systemPackages = with pkgs; [
    # Power management tools
    powertop
    tlp
    acpi
    upower
    
    # Hibernation tools
    systemd
    util-linux
    
    # Battery monitoring
    batmon
  ];
  
  # ACPI configuration
  services.acpid.enable = true;
  
  # UPower for power management
  services.upower.enable = true;
  
  # Power management for NVIDIA GPU
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = true;
  
  # Systemd sleep configuration
  systemd.sleep.extraConfig = ''
    [Sleep]
    HibernateMode=shutdown
    SuspendMode=mem
    HybridSleepMode=suspend
    HibernateState=disk
    SuspendState=mem
    HybridSleepState=disk
  '';
}