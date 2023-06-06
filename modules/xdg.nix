{ config, home-manager, pkgs, ... }:
{
    home-manager.users.${config.user.name}.xdg ={
        enable = true;
        # Until https://github.com/rycee/home-manager/issues/1213 is solved.
        configFile."mimeapps.list".force = true;
        mime.enable = true;
        mimeApps = {
            enable = true;
            defaultApplications = {
                "text/html" = "firefox.desktop";
                "x-scheme-handler/http" = "firefox.desktop";
                "x-scheme-handler/https" = "firefox.desktop";
                "x-scheme-handler/about" = "firefox.desktop";
                "x-scheme-handler/unknown" =  "firefox.desktop";
            };
        };
    };

    environment = {
        sessionVariables = {
            # These are the defaults, and xdg.enable does set them, but due to load
            # order, they're not set before environment.variables are set, which could
            # cause race conditions.
            XDG_CACHE_HOME  = "$HOME/.cache";
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME   = "$HOME/.local/share";
            XDG_BIN_HOME    = "$HOME/.local/bin";
            # Firefox really wants a desktop directory to exist
            XDG_DESKTOP_DIR = "~/tmp";
            # Setting this for Electon apps that do not respect mime default apps
            DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
        };
        variables = {
            __GL_SHADER_DISK_CACHE_PATH = "$XDG_CACHE_HOME/nv";
            CUDA_CACHE_PATH = "$XDG_CACHE_HOME/nv";
            HISTFILE        = "$XDG_DATA_HOME/bash/history";
            INPUTRC         = "$XDG_CONFIG_HOME/readline/inputrc";
            LESSHISTFILE    = "$XDG_CACHE_HOME/lesshst";
            WGETRC          = "$XDG_CONFIG_HOME/wgetrc";
        };

        extraInit = ''
            export XAUTHORITY=/tmp/Xauthority
            [ -e ~/.Xauthority ] && mv -f ~/.Xauthority "$XAUTHORITY"
        '';
    };
}
