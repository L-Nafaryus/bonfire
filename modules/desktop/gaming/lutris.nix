{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.desktop.gaming.lutris;
in {
    options.modules.desktop.gaming.lutris = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        user.packages = with pkgs; [
            lutris
            wine
            winetricks
            gamemode
        ];
    };
}
