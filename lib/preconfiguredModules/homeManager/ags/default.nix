{pkgs, ...}: {
  programs.ags = {
    enable = true;
    extraPackages = with pkgs; [
      libdbusmenu-gtk3 # for system tray
    ];
    configDir = ./ags;
  };
}
