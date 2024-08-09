{
  lib,
  config,
  pkgs,
  bonPkgs,
  ...
}:
with lib; let
  cfg = config.services.zapret;

  createFilterList = name: str: (
    lib.concatStringsSep "\n"
    (map (ip: "add ${name} ${ip}")
      (lib.splitString "\n" (lib.removeSuffix "\n" str)))
  );
in {
  options.services.zapret = {
    enable = mkEnableOption "DPI bypass multi platform service";

    package = mkOption {
      type = types.package;
      default = bonPkgs.zapret;
      defaultText = literalExpression "bonPkgs.zapret";
      description = "The package to use.";
    };

    settings = mkOption {
      type = types.lines;
      default = "";

      example = ''
        TPWS_OPT="--hostspell=HOST --split-http-req=method --split-pos=3 --oob"
        NFQWS_OPT_DESYNC="--dpi-desync-ttl=5"
      '';

      description = ''
        Rules for zapret to work. Run ```nix-shell -p zapret --command blockcheck``` to get values to pass here.

        Config example can be found here https://github.com/bol-van/zapret/blob/master/config.default
      '';
    };

    firewallType = mkOption {
      type = types.enum [
        "iptables"
        "nftables"
      ];
      default = "nftables";
      description = ''
        Which firewall zapret should use.
      '';
    };

    disableIPV4 = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Enable usage of IpV4.
      '';
    };

    disableIPV6 = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Enable usage of IpV6.
      '';
    };

    mode = mkOption {
      type = types.enum [
        "tpws"
        "tpws-socks"
        "nfqws"
        "filter"
        "custom"
      ];
      default = "tpws";
      description = ''
        Which mode zapret should use.
      '';
    };

    # TODO: add filter and anti filter options with optional file paths
    # TODO ipset hashsize and maxelem
  };

  config = mkIf cfg.enable {
    users.users.tpws = {
      isSystemUser = true;
      group = "tpws";
    };

    users.groups.tpws = {};

    systemd.services.zapret = {
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      path = with pkgs; [
        (
          if cfg.firewallType == "iptables"
          then iptables
          else nftables
        )
        gawk
        ipset
      ];

      serviceConfig = {
        Type = "forking";
        Restart = "no";
        TimeoutSec = "30sec";
        IgnoreSIGPIPE = "no";
        KillMode = "none";
        GuessMainPID = "no";
        RemainAfterExit = "no";

        ExecStart = "${cfg.package}/bin/zapret start";
        ExecStop = let
          stop_script = pkgs.writeShellScriptBin "zapret-stop" ''
            ${cfg.package}/bin/zapret stop
              ipset destroy zapret -!
              ipset destroy nozapret -!
          '';
        in "${stop_script}/bin/zapret-stop";
        StandardOutput = "journal";
        StandardError = "journal";

        EnvironmentFile = pkgs.writeText "${cfg.package.pname}-environment" (concatStrings [
          cfg.settings
          ''
            MODE=${cfg.mode}
            FWTYPE=${cfg.firewallType}
            DISABLE_IPV4=${toString cfg.disableIPV4}
            DISABLE_IPV6=${toString cfg.disableIPV6}
          ''
        ]);

        # hardening
        DevicePolicy = "closed";
        KeyringMode = "private";
        PrivateTmp = true;
        PrivateMounts = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ProtectProc = "invisible";
        RemoveIPC = true;
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
      };

      preStart = let
        zapretListFile = pkgs.writeText "zapretList" (createFilterList "zapret" (lib.readFile cfg.package.passthru.antifilter.ipsmart));
        nozapretListFile = pkgs.writeText "nozapretList" (createFilterList "nozapret" ''
          10.0.0.0/8
          169.254.0.0/16
          172.16.0.0/12
          192.168.0.0/16
        '');
      in ''
        ipset create zapret hash:net family inet hashsize 262144 maxelem 522288 -!
        ipset flush zapret
        ipset restore -! < ${zapretListFile}

        ipset create nozapret hash:net family inet hashsize 262144 maxelem 522288 -!
        ipset flush nozapret
        ipset restore -! < ${nozapretListFile}
      '';
    };
  };
}
