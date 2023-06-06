{ config, lib, pkgs, modulesPath, ... }:
{
    imports = [ "${modulesPath}/installer/scan/not-detected.nix" ];

    boot = {
        initrd = {
            availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];
            kernelModules = [];
        };
        extraModulePackages = [];
        kernelModules = [ "kvm-amd" "coretemp" ];
        kernelParams = [];
        kernelPackages = pkgs.linuxPackages_latest;

        # Refuse ICMP echo requests on my desktop/laptop; nobody has any business
        # pinging them, unlike my servers.
        kernel.sysctl."net.ipv4.icmp_echo_ignore_broadcasts" = 1;

        loader = {
            systemd-boot.enable = false;
            efi = {
                canTouchEfiVariables = true;
                efiSysMountPoint = "/boot/efi";
            };
            grub = {
                devices = [ "nodev" ];
                enable = true;
                efiSupport = true;
                # version = 2;
                useOSProber = true;
            };
        };
    };

    # Modules
    modules.hardware = {
        audio.enable = true;
        fs = {
            enable = true;
            ssd.enable = true;
        };
        nvidia.enable = true;
        sensors.enable = true;
    };

    # CPU
    #nix.settings.max-jobs = lib.mkDefault 16;
    #powerManagement.cpuFreqGovernor = "performance";
    hardware.cpu.amd.updateMicrocode = true;

    # Nvidia, OpenGL
    hardware = {
        nvidia.nvidiaSettings = true;
        nvidia.modesetting.enable = true;

        opengl.enable = true;
        opengl.driSupport32Bit = true;
    };

    # Storage
    fileSystems = {
        "/" = {
            device = "/dev/disk/by-uuid/d53d2bcd-36c7-4273-b5b4-6563692ee16c";
            fsType = "ext4";
            options = [ "noatime" ];
        };

        "/boot/efi" = {
            device = "/dev/disk/by-uuid/3117-8F91";
            fsType = "vfat";
        };

        "/home" = {
            device = "/dev/disk/by-uuid/b9e2a42a-4db9-4389-bf75-457bb4da2a30";
            fsType = "ext4";
            options = [ "noatime" ];
        };

        "/mnt/vault" = {
            device = "/dev/disk/by-uuid/34cbaf1c-19c7-412f-8b51-41410f3fee2a";
            fsType = "btrfs";
            options = [
                "nofail" "noauto" "noatime" "x-systemd.automount" "x-systemd.idle-timeout=5min"
                "nodev" "nosuid" "noexec"
            ];
        };
    };

    swapDevices = [];
}
