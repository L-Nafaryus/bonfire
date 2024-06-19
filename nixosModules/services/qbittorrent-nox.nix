{ config, lib, pkgs, ... }:
with lib;
let 
    cfg = config.services.qbittorrent-nox;
in {
    options.services.qbittorrent-nox = {
        enable = mkEnableOption "Enables the qbittorrent-nox services.";

        port = mkOption rec {
            type = types.int;
            default = 6969;
            example = default;
            description = "Torrenting port.";
        };

        webuiPort = mkOption rec {
            type = types.port;
            default = 8080;
            example = default;
            description = "WebUI port.";
        };

        dataDir = mkOption rec {
            type = types.path;
            default = "/var/lib/qbittorrent-nox";
            example = default;
            description = "Directory to store qbittorrent-nox data files.";
        };

        user = mkOption {
            type = types.str;
            default = "qbittorrent-nox";
            description = "User account under which qbittorrent-nox runs.";
        };

        group = mkOption {
            type = types.str;
            default = "qbittorrent-nox";
            description = "Group under which qbittorrent-nox runs.";
        };

        openFirewall = mkOption {
            type = types.bool;
            default = false;
            description = "Open `services.qbittorrent-nox.port`.";
        };

        package = mkOption {
            type = types.package;
            default = pkgs.qbittorrent-nox;
            defaultText = literalExpression "pkgs.qbittorrent-nox";
            description = "The qbittorrent package to use.";
        };
    };

    config = mkIf cfg.enable {
        users.users.qbittorrent-nox = {
            description = "qbittorrent-nox service user.";
            home = cfg.dataDir;
            createHome = true;
            isSystemUser = true;
            group = "qbittorrent-nox";
        };
        users.groups.qbittorrent-nox = {};

        networking.firewall = mkIf cfg.openFirewall {
            allowedTCPPorts = [ cfg.port ];
            allowedUDPPorts = [ cfg.port ];
        };

        systemd.services.qbittorrent-nox = {
            wantedBy = [ "multi-user.target" ];
            after = [ "network.target" ];

            serviceConfig = {
                Type = "simple";
                ExecStart = "${cfg.package}/bin/qbittorrent-nox --torrenting-port=${toString cfg.port} --webui-port=${toString cfg.webuiPort}";
                Restart = "always";
                User = cfg.user;
                Group = cfg.group;
                WorkingDirectory = cfg.dataDir;
                # Runtime directory and mode
                RuntimeDirectory = "qbittorrent-nox";
                RuntimeDirectoryMode = "0755";
                # Proc filesystem
                ProcSubset = "pid";
                ProtectProc = "invisible";
                # Access write directories
                ReadWritePaths = [ cfg.dataDir ];
                UMask = "0027";
                # Capabilities
                CapabilityBoundingSet = "";
                # Security
                NoNewPrivileges = true;
                # Sandboxing
                ProtectSystem = "strict";
                ProtectHome = true;
                PrivateTmp = true;
                PrivateDevices = true;
                PrivateUsers = true;
                ProtectHostname = true;
                ProtectClock = true;
                ProtectKernelTunables = true;
                ProtectKernelModules = true;
                ProtectKernelLogs = true;
                ProtectControlGroups = true;
                RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
                RestrictNamespaces = true;
                LockPersonality = true;
                MemoryDenyWriteExecute = true;
                RestrictRealtime = true;
                RestrictSUIDSGID = true;
                RemoveIPC = true;
                PrivateMounts = true;
            };

        };
    };
}
