{
  config,
  lib,
  pkgs,
  bonLib,
  ...
}:
with lib; let
  cfg = config.services.conduit;
  format = pkgs.formats.toml {};
  configFile = pkgs.writeText "config.toml" ''
    ${bonLib.toTOML {global = cfg.settings.global // lib.optionals (cfg.turn_secret_file != null) {turn_secret = "#turn_secret#";};}}
  '';
in {
  options.services.conduit = {
    enable = mkEnableOption "conduit";

    extraEnvironment = mkOption {
      type = types.attrsOf types.str;
      description = "Extra Environment variables to pass to the conduit server.";
      default = {};
      example = {RUST_BACKTRACE = "yes";};
    };

    package = mkOption {
      type = types.package;
      default = pkgs.matrix-conduit;
      defaultText = literalExpression "pkgs.matrix-conduit";
      description = "The package to use.";
    };

    turn_secret_file = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "The path to the file with TURN secret.";
    };

    settings = mkOption {
      type = types.submodule {
        #freeformType = format.type;
        options = {
          global.server_name = mkOption {
            type = types.str;
            example = "example.com";
            description = "The server_name is the name of this server. It is used as a suffix for user # and room ids.";
          };
          global.port = mkOption {
            type = types.port;
            default = 6167;
            description = "The port Conduit will be running on. You need to set up a reverse proxy in your web server (e.g. apache or nginx), so all requests to /_matrix on port 443 and 8448 will be forwarded to the Conduit instance running on this port";
          };
          global.max_request_size = mkOption {
            type = types.ints.positive;
            default = 20000000;
            description = "Max request size in bytes. Don't forget to also change it in the proxy.";
          };
          global.allow_registration = mkOption {
            type = types.bool;
            default = false;
            description = "Whether new users can register on this server.";
          };
          global.allow_encryption = mkOption {
            type = types.bool;
            default = true;
            description = "Whether new encrypted rooms can be created. Note: existing rooms will continue to work.";
          };
          global.allow_federation = mkOption {
            type = types.bool;
            default = true;
            description = ''
              Whether this server federates with other servers.
            '';
          };
          global.trusted_servers = mkOption {
            type = types.listOf types.str;
            default = ["matrix.org"];
            description = "Servers trusted with signing server keys.";
          };
          global.address = mkOption {
            type = types.str;
            default = "::1";
            description = "Address to listen on for connections by the reverse proxy/tls terminator.";
          };
          global.database_path = mkOption {
            type = types.str;
            default = "/var/lib/conduit/";
            readOnly = true;
            description = ''
              Path to the conduit database, the directory where conduit will save its data.
              Note that due to using the DynamicUser feature of systemd, this value should not be changed
              and is set to be read only.
            '';
          };
          global.database_backend = mkOption {
            type = types.enum ["sqlite" "rocksdb"];
            default = "sqlite";
            example = "rocksdb";
            description = ''
              The database backend for the service. Switching it on an existing
              instance will require manual migration of data.
            '';
          };
          global.allow_check_for_updates = mkOption {
            type = types.bool;
            default = false;
            description = ''
              Whether to allow Conduit to automatically contact
              <https://conduit.rs> hourly to check for important Conduit news.

              Disabled by default because nixpkgs handles updates.
            '';
          };
          global.well_known.client = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The URL that clients should use to connect to Conduit.";
          };
          global.well_known.server = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The hostname and port servers should use to connect to Conduit.";
          };
          global.turn_uris = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "The TURN URIs.";
          };
          global.turn_secret = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "The TURN secret.";
          };
          global.turn_ttl = mkOption {
            type = types.int;
            default = 86400;
            description = "The TURN TTL in seconds.";
          };
        };
      };
      default = {};
      description = ''
        Generates the conduit.toml configuration file. Refer to
        <https://docs.conduit.rs/configuration.html>
        for details on supported values.
        Note that database_path can not be edited because the service's reliance on systemd StateDir.
      '';
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.global.turn_secret != null -> cfg.turn_secret_file == null;
        message = "settings.global.turn_secret and turn_secret_file cannot be set at the same time";
      }
    ];

    users.users.conduit = {
      description = "Conduit service user.";
      isSystemUser = true;
      group = "conduit";
    };
    users.groups.conduit = {};

    systemd.services.conduit = let
      runConfig = "/run/conduit/config.toml";
    in {
      description = "Conduit Matrix Server";
      documentation = ["https://gitlab.com/famedly/conduit/"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      environment = mkMerge [
        {CONDUIT_CONFIG = runConfig;}
        cfg.extraEnvironment
      ];
      preStart = ''
        cat ${configFile} > ${runConfig}
        ${lib.optionalString (cfg.turn_secret_file != null) ''
          ${pkgs.replace-secret}/bin/replace-secret \
            "#turn_secret#" \
            ${cfg.turn_secret_file} \
            ${runConfig}
        ''}
        chmod 640 ${runConfig}
      '';
      serviceConfig = {
        User = "conduit";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateUsers = true;
        RestrictAddressFamilies = ["AF_INET" "AF_INET6"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
        StateDirectory = "conduit";
        StateDirectoryMode = "0700";
        RuntimeDirectory = "conduit";
        ExecStart = "${cfg.package}/bin/conduit";
        Restart = "on-failure";
        RestartSec = 10;
        StartLimitBurst = 5;
        UMask = "077";
      };
    };

    systemd.tmpfiles.rules = [
      "d /run/conduit 0700 conduit conduit - -"
    ];
  };
}
