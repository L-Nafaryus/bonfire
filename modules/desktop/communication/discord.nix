{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let 
    cfg = config.modules.desktop.communication.discord;
in {
    options.modules.desktop.communication.discord = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        user.packages = with pkgs; [
            discord
            (makeDesktopItem {
                name = "discord-x11";
                desktopName = "Discord";
                genericName = "Discord via xwayland";
                icon = "discord";
                exec = "${discord}/bin/discord --use-gl=desktop";
                categories = [ "Network" ];
            })
        ];
    };
}
