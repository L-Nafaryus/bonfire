{
  pkgs,
  lib,
  config,
  hmConfig,
  ...
}: {
  programs.nushell = {
    enable = true;
    # The config.nu can be anywhere you want if you like to edit your Nushell with Nu
    #configFile.source = ./.../config.nu;
    # for editing directly to config.nu
    extraConfig = ''
      let carapace_completer = {|spans|
          carapace $spans.0 nushell ...$spans | from json
      }
      $env.config = {
       show_banner: false,
       completions: {
           case_sensitive: false # case-sensitive completions
           quick: true    # set to false to prevent auto-selecting completions
           partial: true    # set to false to prevent partial filling of the prompt
           algorithm: "fuzzy"
           external: {
               enable: true
               max_results: 100
               completer: $carapace_completer
             }
           }
      }
    '';

    environmentVariables = {
      GNUPGHOME = hmConfig.programs.gpg.homedir;
      SSH_AUTH_SOCK = "/run/user/1000/ssh-agent";
      EDITOR = "${lib.getExe' hmConfig.programs.helix.package "hx"}";
    };
  };

  # completion
  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
  };

  # prompt
  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    enableBashIntegration = true;
    settings = {
      add_newline = true;
      format = ''
        $all $fill $time
        $character
      '';
      fill = {
        symbol = " ";
      };
      line_break = {
        disabled = true;
      };
      directory = {
        truncate_to_repo = false;
      };
      time = {
        disabled = false;
        use_12hr = true;
      };
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
      nix_shell = {
        symbol = " ";
        heuristic = true;
      };
    };
  };
}
