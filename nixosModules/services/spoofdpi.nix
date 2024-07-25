{
  config,
  lib,
  bonPkgs,
  ...
}:
with lib; let
  cfg = config.services.spoofdpi;
in {
  options.services.spoofdpi = {
    enable = mkEnableOption "SpoofDPI service";

    package = mkOption {
      type = types.package;
      default = bonPkgs.spoofdpi;
      defaultText = literalExpression "bonPkgs.spoofdpi";
      description = "The package to use.";
    };

    address = mkOption rec {
      type = types.str;
      default = "127.0.0.1";
      example = default;
      description = "Listen address.";
    };

    port = mkOption rec {
      type = types.port;
      default = 8080;
      example = default;
      description = "Port.";
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open `services.spoofdpi.port`.";
    };

    dns = mkOption rec {
      type = types.str;
      default = "8.8.8.8";
      example = default;
      description = "DNS address.";
    };

    dnsPort = mkOption rec {
      type = types.port;
      default = 53;
      example = default;
      description = "DNS port.";
    };

    doh = mkEnableOption "DOH";

    windowSize = mkOption rec {
      type = types.int;
      default = 50;
      example = default;
      description = "Window size for fragmented client hello.";
    };

    timeout = mkOption rec {
      type = types.int;
      default = 2000;
      example = default;
      description = "Timeout in milliseconds.";
    };

    pattern = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Bypass DPI only on packets matching this regex pattern.";
    };

    bypassUrls = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Bypass DPI only on this urls.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.spoofdpi = {
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        Restart = "on-failure";
        ExecStart = ''
          ${lib.getExe cfg.package} \
              -no-banner \
              -addr ${cfg.address} \
              -port ${toString cfg.port} \
              -dns-addr ${cfg.dns} \
              -dns-port ${toString cfg.dnsPort} \
              ${lib.optionalString cfg.doh ''-enable-doh \''}
              -window-size ${toString cfg.windowSize} \
              -timeout ${toString cfg.timeout} \
              ${lib.optionalString (cfg.pattern != null) ''-pattern ${cfg.pattern} \''}
              ${lib.concatStringsSep " " (map (url: "-url ${url}") cfg.bypassUrls)}
        '';
        DynamicUser = "yes";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.port];
    };
  };
}
