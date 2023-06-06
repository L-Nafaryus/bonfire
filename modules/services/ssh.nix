{ options, config, lib, ... }:
with lib;
with lib.custom;
let
    cfg = config.modules.services.ssh;
in {
    options.modules.services.ssh = {
        enable = mkBoolOpt false;
    };

    config = mkIf cfg.enable {
        services.openssh = {
            enable = true;
	    settings = {
                KbdInteractiveAuthentication = false;
                PasswordAuthentication = false;
	    };
        };

        user.openssh.authorizedKeys.keys =
            if config.user.name == "nafaryus"
            then [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9pBG3Ak8hO4eQFA8roajDeZkKSPv2NsgZADQoV8bNEvsqNssqvpnoBKZCCKFv+Hqvf0tcTcdkRedUJh+9f/CI8dEuYiNzRyCFjYnfyFyUlEjNh/MaTonJEFEO4QsbapxQx+Buc+/jPCdwhUEbf1jvJV0oQy7TptXOn87cYQSuqqeubv+YwBqXUfMIFbsxH+ePZ9rX+N9sLdYpW2k9W1i8g2oNPrEpa3ICW2qhf/bshUhmDLB9te+vt1qMu0jmzpllnbaJJ57rDuL6XLaWqU/PD6uC0j1axf8AMxf00YvrLvMJ+T9hWlLe0mwNsgkhRzBE2/T+PYkUfvWvzqGLtIBZ nafaryus" ]
            else [];
    };
}
