{ pkgs, config, lib, ... }:
{
    imports = [
        ../common.nix
        ./hardware-configuration.nix
    ];

    ## Modules
    modules = {
        desktop = {
            gnome.enable = true;
            audio.enable = true;
            browsers = {
                default = "firefox";
                firefox.enable = true;
            };
            communication = {
                discord.enable = true;
            };
            documents.enable = true;
            editors = {
                    vscodium.enable = true;
            };
            gaming = {
                steam.enable = true;
            lutris.enable = true;
            };
            graphics = {
                enable = true;
                models.enable = true;
            };
            media = {
                recording.enable = true;
            };
            term = {
                default = "kgx";
            };
            vm = {
                qemu.enable = true;
            };
        };
        dev = {
            cc.enable = true;
            rust.enable = true;
            python.enable = true;
        };
        editors = {
            default = "nvim";
            emacs = {
                enable = true;
                doom.enable = true;
            };
            vim.enable = true;
        };
        shell = {
            direnv.enable = true;
            git.enable    = true;
            gnupg.enable  = true;
            tmux.enable   = true;
            zsh.enable    = true;
            taskwarrior.enable = true;
        };
        services = {
            ssh.enable = true;
            nginx.enable = true;
            podman.enable = true;
        };
    };

    networking = {
        networkmanager.enable = true;
        useDHCP = lib.mkDefault true;
        firewall.enable = true;
    };

    ## Local config
    programs = {
        dconf.enable = true;
        ssh.startAgent = true;
    };

    ## Services
    services.printing.enable = true;

    services.xserver = {
        layout = "us";
        xkbVariant = "";
        videoDrivers = [ "nvidia" ];
    };

    services.openssh.startWhenNeeded = true;
}
