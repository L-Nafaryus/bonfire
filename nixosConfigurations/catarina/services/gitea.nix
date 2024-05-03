{ config, ... }:
{
    services.postgresql = {
        enable = true;
        authentication = ''
            # Type      Database    DB-User     Auth-Method     Ident-Map(optional)
            local       git         all         ident           map=gitea-users
        '';
        identMap = ''
            # MapName       System-User     DB-User
            gitea-users     git           git
        '';
        ensureDatabases = [ "git" ];
    };

    services.gitea = {
        enable = true;

        user = "git";
        group = "gitea";
        stateDir = "/var/lib/gitea";

        settings = {
            server = {
                DOMAIN = "vcs.elnafo.ru";
                ROOT_URL = "https://vcs.elnafo.ru/";
                HTTP_ADDRESS = "127.0.0.1";
                HTTP_PORT = 3001;
            };

            session.COOKIE_SECURE = true;

            mailer = {
                ENABLED = true;
                FROM = "Elnafo VCS <git@elnafo.ru>";
                PROTOCOL = "smtps";
                SMTP_ADDR = "smtp.elnafo.ru";
                SMTP_PORT = 465;
                USER = "git@elnafo.ru";
                USE_CLIENT_CERT = true;
                CLIENT_CERT_FILE = "${config.security.acme.certs."elnafo.ru".directory}/cert.pem";
                CLIENT_KEY_FILE = "${config.security.acme.certs."elnafo.ru".directory}/key.pem";
            };

            service = {
                DISABLE_REGISTRATION = true;
                REGISTER_EMAIL_CONFIRM = true;
                ENABLE_NOTIFY_MAIL = true;
            };

            other = {
                SHOW_FOOTER_VERSION = false;
                SHOW_FOOTER_TEMPLATE_LOAD_TIME = false;
            };

            indexer = {
                REPO_INDEXER_ENABLED = true;
            };
        };

        mailerPasswordFile = config.sops.secrets."gitea/mail".path;

        database = {
            type = "postgres";
            passwordFile = config.sops.secrets."database/git".path;
            name = "git";
            user = "git";
        };

        lfs.enable = true;

        appName = "Elnafo VCS";
    };

    users.users.${config.services.gitea.user} = {
        description = "Gitea Service";
        home = config.services.gitea.stateDir;
        useDefaultShell = true;
        group = config.services.gitea.group;
        extraGroups = [ "nginx" ];
        isSystemUser = true;
    };

    services.nginx.virtualHosts."vcs.elnafo.ru" = {
        forceSSL = true;
        useACMEHost = "elnafo.ru";
        locations."/".proxyPass = "http://127.0.0.1:3001";
    };

    services.gitea-actions-runner = {
        instances = {
            master = {
                enable = true;
                name = "master";
                url = config.services.gitea.settings.server.ROOT_URL;
                tokenFile = config.sops.secrets."gitea-runner/master-token".path;
                labels = [
                    "ubuntu-latest:docker://gitea/runner-images:ubuntu-latest"
                    "nix-minimal:docker://vcs.elnafo.ru/l-nafaryus/nix-minimal:latest"
                    "nix-runner:docker://vcs.elnafo.ru/l-nafaryus/nix-runner:latest"
                ];
                settings.container.network = "host";
            };
        };
    };

}
