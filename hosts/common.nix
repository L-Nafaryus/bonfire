{ config, lib, ... }:
with builtins;
with lib;
{
    networking = {
        extraHosts = ''
            192.168.156.1     router.home
            192.168.156.35    elnafo.home
        '';
        firewall = {
            enable = true;
            allowedTCPPorts = [ 80 443 ];
            #allowedUDPPortRanges = [
            #    { from = 4000; to = 4007; }
            #    { from = 8000; to = 8010; }
            #];
        };
    };


    ## Location config -- since Toronto is my 127.0.0.1
    time.timeZone = mkDefault "Asia/Yekaterinburg";

    i18n.defaultLocale = mkDefault "en_US.UTF-8";
    i18n.extraLocaleSettings = {
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
}
