{ options, config, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.desktop.audio;
in {
    options.modules.desktop.audio = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        user.packages = with pkgs; [
            lollypop
            vlc
            beets
            flacon
        ];
    };
}
