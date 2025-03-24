{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  programs.yazi = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };
}
