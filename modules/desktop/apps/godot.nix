{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.desktop.apps.godot;
in {
    options.modules.desktop.apps.godot = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        user.packages = with pkgs; [
            godot
        ];
    };
}
