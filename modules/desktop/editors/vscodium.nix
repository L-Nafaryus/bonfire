{ config, options, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.desktop.editors.vscodium;
in {
    options.modules.desktop.editors.vscodium = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        user.packages = with pkgs; [
            vscodium-fhs
        ];
    };
}
