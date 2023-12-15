{ config, lib, ... }:
{
# Boot 
    boot = {
        loader.systemd-boot.enable = true;
        loader.systemd-boot.configurationLimit = 2;
        loader.efi.canTouchEfiVariables = true;

        tmp.useTmpfs = lib.mkDefault true;
        tmp.cleanOnBoot = lib.mkDefault (!config.boot.tmp.useTmpfs);

        initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
        initrd.kernelModules = [ ];
        kernelModules = [ "kvm-amd" "tcp_bbr" "coretemp" "nct6775" ];
        extraModulePackages = [ ];

        kernel.sysctl = {
            # The Magic SysRq key is a key combo that allows users connected to the
            # system console of a Linux kernel to perform some low-level commands.
            # Disable it, since we don't need it, and is a potential security concern.
            "kernel.sysrq" = 0;

            ## TCP hardening
            # Prevent bogus ICMP errors from filling up logs.
            "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
            # Reverse path filtering causes the kernel to do source validation of
            # packets received from all interfaces. This can mitigate IP spoofing.
            "net.ipv4.conf.default.rp_filter" = 1;
            "net.ipv4.conf.all.rp_filter" = 1;
            # Do not accept IP source route packets
            "net.ipv4.conf.all.accept_source_route" = 0;
            "net.ipv6.conf.all.accept_source_route" = 0;
            # Don't send ICMP redirects
            "net.ipv4.conf.all.send_redirects" = 0;
            "net.ipv4.conf.default.send_redirects" = 0;
            # Refuse ICMP redirects (MITM mitigations)
            "net.ipv4.conf.all.accept_redirects" = 0;
            "net.ipv4.conf.default.accept_redirects" = 0;
            "net.ipv4.conf.all.secure_redirects" = 0;
            "net.ipv4.conf.default.secure_redirects" = 0;
            "net.ipv6.conf.all.accept_redirects" = 0;
            "net.ipv6.conf.default.accept_redirects" = 0;
            # Protects against SYN flood attacks
            "net.ipv4.tcp_syncookies" = 1;
            # Incomplete protection again TIME-WAIT assassination
            "net.ipv4.tcp_rfc1337" = 1;

            ## TCP optimization
            # TCP Fast Open is a TCP extension that reduces network latency by packing
            # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
            # both incoming and outgoing connections:
            "net.ipv4.tcp_fastopen" = 3;
            # Bufferbloat mitigations + slight improvement in throughput & latency
            "net.ipv4.tcp_congestion_control" = "bbr";
            "net.core.default_qdisc" = "cake";
        };
    };

# Security
    security = {
        protectKernelImage = true;
        acme.acceptTerms = true;
        sudo.extraConfig = ''Defaults timestamp_timeout=30'';
        rtkit.enable = true;
    };

    users.users.root.initialPassword = "nixos";

# Filesystem
    fileSystems = {
        "/" = { 
            device = "/dev/disk/by-uuid/77e1fc4b-31af-46e8-8b9c-907e4113b31b";
            fsType = "ext4";
        };

        "/boot" = { 
            device = "/dev/disk/by-uuid/92C6-2268";
            fsType = "vfat";
        };

        "/mnt/ext" = { 
            device = "/dev/disk/by-uuid/4b47d83c-42da-4e78-b279-7726dfbdfde7";
            fsType = "ext4";
        };
    };

    swapDevices = [ ];

    services.fstrim.enable = true;

# Hardware etc
    hardware = {
        enableRedistributableFirmware = true;

        cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

        nvidia.nvidiaSettings = true;
        nvidia.modesetting.enable = true;
        
        opengl.enable = true;
        opengl.driSupport32Bit = true;

        bluetooth.enable = true;

        pulseaudio.enable = false;
    };

    sound.enable = true;

    networking = {
        networkmanager.enable = true;
        useDHCP = lib.mkDefault true;
        hostName = "astora";
        extraHosts = '''';

        firewall = {
            enable = true;
            allowedTCPPorts = [ 80 443 ];
        };
    };

# Common
    time.timeZone = "Asia/Yekaterinburg";

    i18n = {
        defaultLocale = "en_US.UTF-8";
        extraLocaleSettings = {
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
    };


}
