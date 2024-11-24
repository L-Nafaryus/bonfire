{
  config,
  lib,
  pkgs,
  ...
}: {
  # Boot
  boot = {
    kernelModules = ["kvm-amd"];
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
  };

  users.users.root.initialPassword = "nixos";

  # Filesystem
  fileSystems = {
    "/media/steam-library" = {
      device = "/dev/disk/by-label/siegward";
      fsType = "btrfs";
      options = ["subvol=steam-library" "compress=zstd"];
    };

    "/media/lutris" = {
      device = "/dev/disk/by-label/siegward";
      fsType = "btrfs";
      options = ["subvol=lutris" "compress=zstd"];
    };
  };

  services.fstrim.enable = true;

  # Hardware etc
  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    nvidia.nvidiaSettings = true;
    nvidia.modesetting.enable = true;
    nvidia.open = false;

    graphics.enable = true;
    graphics.enable32Bit = true;

    bluetooth.enable = true;

    pulseaudio.enable = false;
  };

  networking = {
    networkmanager = {
      enable = true;
      enableStrongSwan = true;
      plugins = with pkgs; [networkmanager-l2tp];
    };
  };
}
