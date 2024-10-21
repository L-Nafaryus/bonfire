{
  pkgs,
  lib,
  config,
  ...
}:
lib.mkIf config.programs.hyprland.enable {
  services.greetd = let
    hyprConfig = pkgs.writeText "greetd-hyprland-config" ''
      exec-once = ${lib.getExe pkgs.greetd.regreet}; hyprctl dispatch exit
    '';
  in {
    enable = true;
    settings = {
      default_session = {
        command = "${lib.getExe config.programs.hyprland.package} --config ${hyprConfig}";
        user = "greeter";
      };
    };
  };

  programs.regreet = {
    enable = true;
    settings = {
      GTK = {
        application_prefer_dark_theme = true;
      };
      appearance = {
        greeting_msg = "Hey, you. You're finally awake.";
      };
    };
  };
}
