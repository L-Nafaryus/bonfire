{ config, lib, pkgs, ... }:
with lib; 
let 
    cfg = config.services.papermc;

    eulaFile = builtins.toFile "eula.txt" ''
        # eula.txt managed by NixOS Configuration
        eula=true
    '';

    whitelistFile = pkgs.writeText "whitelist.json"
        (builtins.toJSON cfg.whitelist);

    opsFile = pkgs.writeText "ops.json"
        (builtins.toJSON cfg.ops);

    cfgToString = v: if builtins.isBool v then boolToString v else toString v;

    serverPropertiesFile = let 
        serverProperties' = if (cfg.rconPasswordFile == null) then cfg.serverProperties else 
            (removeAttrs cfg.serverProperties [ "rcon.password" ]);
    in pkgs.writeText "server.properties" (''
        # server.properties managed by NixOS configuration
    '' + concatStringsSep "\n" (mapAttrsToList
        (n: v: "${n}=${cfgToString v}") serverProperties') + 
        lib.optionalString (cfg.rconPasswordFile != null) "\nrcon.password=#rconpass#");

    stopScript = pkgs.writeShellScript "minecraft-server-stop" ''
        echo stop > ${config.systemd.sockets.papermc.socketConfig.ListenFIFO}

        # Wait for the PID of the minecraft server to disappear before
        # returning, so systemd doesn't attempt to SIGKILL it.
        while kill -0 "$1" 2> /dev/null; do
        sleep 1s
        done
    '';

    defaultServerPort = 25565;

    serverPort = cfg.serverProperties.server-port or defaultServerPort;

    rconPort = if cfg.serverProperties.enable-rcon or false
        then cfg.serverProperties."rcon.port" or 25575
        else null;

    queryPort = if cfg.serverProperties.enable-query or false
        then cfg.serverProperties."query.port" or 25565
        else null;

in {
    options.services.papermc = {
        enable = mkEnableOption "PaperMC service";
        
        openFirewall = mkOption {
            type = types.bool;
            default = false;
            description = ''
                Whether to open ports in the firewall for the server.
            '';
        };

        eula = mkOption {
            type = types.bool;
            default = false;
            description = ''
                Whether you agree to [Mojangs EULA](https://account.mojang.com/documents/minecraft_eula). 
                This option must be set to `true` to run Minecraft server.
            '';
        };

        dataDir = mkOption {
            type = types.path;
            default = "/var/lib/papermc";
            description = ''
                Directory to store Minecraft database and other state/data files.
            '';
        };

        whitelist = mkOption {
            type = types.listOf types.attrs;
            default = {};
            description = ''
                This is a mapping from Minecraft usernames to UUIDs.
            '';
        };

        ops = mkOption {
            type = types.listOf types.attrs;
            description = "Whitelist with players / operators.";
            default = [];
        };

        serverProperties = mkOption {
            type = with types; attrsOf (oneOf [ bool int str ]);
            default = {
                "rcon.password" = mkIf (cfg.rconPasswordFile != null) "#rconpass#";
            };
            example = literalExpression ''
                {
                    server-port = 43000;
                    difficulty = 3;
                    gamemode = 1;
                    max-players = 5;
                    motd = "NixOS Minecraft server!";
                    white-list = true;
                    enable-rcon = true;
                    "rcon.password" = "hunter2";
                }
            '';
            description = ''
                Minecraft server properties for the server.properties file. See
                <https://minecraft.gamepedia.com/Server.properties#Java_Edition_3>
                for documentation on these values.
            '';
        };

        rconPasswordFile = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Path to file with rcon password.";
            example = "/var/lib/secrets/papermc/rconpw";
        };

        package = mkPackageOption pkgs "papermc" {};

        jvmOpts = mkOption {
            type = types.separatedString " ";
            default = "-Xmx2048M -Xms2048M";
            # Example options from https://minecraft.gamepedia.com/Tutorials/Server_startup_script
            example = "-Xms4092M -Xmx4092M -XX:+UseG1GC -XX:+CMSIncrementalPacing "
                + "-XX:+CMSClassUnloadingEnabled -XX:ParallelGCThreads=2 "
                + "-XX:MinHeapFreeRatio=5 -XX:MaxHeapFreeRatio=10";
            description = "JVM options for the Minecraft server.";
        };

        extraPreStart = mkOption {
            type = types.lines;
            description = "Extra shell commands for service pre-start hook.";
            default = '''';
        }; 
    };

    config = mkIf cfg.enable {
        users.users.papermc = {
            description     = "Minecraft server service user.";
            home            = cfg.dataDir;
            createHome      = true;
            isSystemUser    = true;
            group           = "papermc";
        };
        users.groups.papermc = {};

        systemd.sockets.papermc = {
            bindsTo = [ "papermc.service" ];
            socketConfig = {
                ListenFIFO = "/run/papermc.stdin";
                SocketMode = "0660";
                SocketUser = "papermc";
                SocketGroup = "papermc";
                RemoveOnStop = true;
                FlushPending = true;
            };
        };

        systemd.services.papermc = {
            description   = "PaperMC Service";
            wantedBy      = [ "multi-user.target" ];
            requires      = [ "papermc.socket" ];
            after         = [ "network.target" "papermc.socket" ];

            serviceConfig = {
                ExecStart = "${cfg.package}/bin/minecraft-server ${cfg.jvmOpts}";
                ExecStop = "${stopScript} $MAINPID";
                Restart = "always";
                User = "papermc";
                WorkingDirectory = cfg.dataDir;

                StandardInput = "socket";
                StandardOutput = "journal";
                StandardError = "journal";

                # Hardening
                CapabilityBoundingSet = [ "" ];
                DeviceAllow = [ "" ];
                LockPersonality = true;
                PrivateDevices = true;
                PrivateTmp = true;
                PrivateUsers = true;
                ProtectClock = true;
                ProtectControlGroups = true;
                ProtectHome = true;
                ProtectHostname = true;
                ProtectKernelLogs = true;
                ProtectKernelModules = true;
                ProtectKernelTunables = true;
                ProtectProc = "invisible";
                RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
                RestrictNamespaces = true;
                RestrictRealtime = true;
                RestrictSUIDSGID = true;
                SystemCallArchitectures = "native";
                UMask = "0077";
            };

            preStart = let 
                replaceSecretBin = "${pkgs.replace-secret}/bin/replace-secret";
            in ''
                ln -sf ${eulaFile} eula.txt

                cp -b --suffix=.stateful ${whitelistFile} whitelist.json
                cp -b --suffix=.stateful ${opsFile} ops.json
                cp -b --suffix=.stateful ${serverPropertiesFile} server.properties

                chmod +w whitelist.json ops.json server.properties

                ${lib.optionalString (cfg.rconPasswordFile != null) ''
                    ${replaceSecretBin} '#rconpass#' '${cfg.rconPasswordFile}' server.properties
                ''}
            '' + cfg.extraPreStart;
        };

        networking.firewall = mkIf cfg.openFirewall ({
            allowedUDPPorts = [ serverPort ];
            allowedTCPPorts = [ serverPort ]
                ++ optional (queryPort != null) queryPort
                ++ optional (rconPort != null) rconPort;
            });

        assertions = [
            { assertion = cfg.eula;
                message = "You must agree to Mojangs EULA to run minecraft-server."
                + " Read https://account.mojang.com/documents/minecraft_eula and"
                + " set `services.minecraft-server.eula` to `true` if you agree.";
            }
        ];
    };
}
