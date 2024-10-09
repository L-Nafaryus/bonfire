{
  config,
  lib,
}: {
  catarina = {
    sops = {
      defaultSopsFile = ./catarina.yaml;
      age.keyFile = "/var/lib/secrets/sops-nix/catarina.txt";
      secrets = {
        "dns" = {};

        "users/root" = {neededForUsers = true;};
        "users/l-nafaryus" = {neededForUsers = true;};

        "database/git" = {
          owner = "git";
          group = "gitea";
        };

        "mail/l-nafaryus" = {};
        "mail/git" = {};
        "mail/kirill" = {};

        "gitea/mail" = {
          owner = "git";
          group = "gitea";
        };
        "gitea-runner/master-token" = {};

        "papermc/rcon" = lib.mkIf config.services.papermc.enable {
          owner = "papermc";
          group = "papermc";
        };

        discordToken = {
          owner = "oscuro";
          group = "oscuro";
        };

        "nix-store/cache-key" = lib.mkIf config.services.nix-serve.enable {
          owner = "nix-serve";
          group = "nix-serve";
          mode = "0600";
        };

        coturn-secret = lib.mkIf config.services.coturn.enable {
          owner = "turnserver";
          group = "turnserver";
          key = "matrix/coturn-secret";
        };

        turn-secret = lib.mkIf config.services.conduit.enable {
          owner = "conduit";
          group = "conduit";
          key = "matrix/coturn-secret";
        };
      };
    };

    mailAccounts = {
      "l.nafaryus@elnafo.ru" = {
        hashedPasswordFile = config.sops.secrets."mail/l-nafaryus".path;
        aliases = ["l-nafaryus@elnafo.ru"];
      };
      "kirill@elnafo.ru" = {
        hashedPasswordFile = config.sops.secrets."mail/kirill".path;
      };
      "git@elnafo.ru" = {
        hashedPasswordFile = config.sops.secrets."mail/git".path;
      };
    };
  };
}
