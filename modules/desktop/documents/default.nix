{ options, config, lib, pkgs, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.desktop.documents;
in {
    options.modules.desktop.documents = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        user.packages = with pkgs; [
            onlyoffice-bin
            tectonic
        ];
    };
}
