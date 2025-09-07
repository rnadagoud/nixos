{ config, pkgs, ... }:

{
  # Hardware-specific configuration for Ryzen 3600 + 1660Ti + NVMe
  
  # Enable hardware acceleration
  hardware.enableRedistributableFirmware = true;
  
  # NVIDIA GPU configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  # AMD CPU microcode
  hardware.cpu.amd.updateMicrocode = true;
  
  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  # NVMe optimization
  boot.kernelParams = [
    # NVMe performance
    "nvme_core.default_ps_max_latency_us=0"
    # AMD optimizations
    "amd_iommu=on"
    "iommu=pt"
    # Power management
    "processor.max_cstate=1"
    "idle=nomwait"
  ];
  
  # Hardware-specific kernel modules
  boot.kernelModules = [ "kvm-amd" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  
  # Blacklist nouveau
  boot.blacklistedKernelModules = [ "nouveau" ];
  
  # Hardware sensors
  hardware.sensor.iio.enable = true;
  
  # Enable TPM for disk unlocking
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    abrmd.enable = true;
  };
  
  # Secure boot support
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Enable hibernation support
  boot.resumeDevice = "/dev/disk/by-label/swap";
  boot.kernelParams = config.boot.kernelParams ++ [
    "resume_offset=0"
  ];
}