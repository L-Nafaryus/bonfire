{
  config,
  pkgs,
  ...
}: {
  # Users
  users.users.root.hashedPasswordFile = config.sops.secrets."users/root".path;

  users.users.l-nafaryus = {
    isNormalUser = true;
    description = "L-Nafaryus";
    extraGroups = ["networkmanager" "wheel"];
    group = "users";
    uid = 1000;
    shell = pkgs.fish;
    hashedPasswordFile = config.sops.secrets."users/l-nafaryus".path;
  };

  users.users.nginx.extraGroups = ["acme" "papermc"];
}
