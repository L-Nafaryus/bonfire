{
  pkgs,
  lib,
  bonLib,
  extraPaths ? [],
  ...
}: let
  user = "postgres";
  dataDir = "/var/lib/postgresql";
  entryPoint = pkgs.writeTextDir "entrypoint.sh" ''
    initdb -U ${user}
    postgres -k ${dataDir}
  '';
in
  pkgs.dockerTools.buildImage {
    name = "postgresql";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      pathsToLink = ["/bin" "/etc" "/"];
      paths = with pkgs;
        [
          bash
          postgresql
          entryPoint
        ]
        ++ extraPaths;
    };
    runAsRoot = with pkgs; ''
      #!${runtimeShell}
      ${dockerTools.shadowSetup}
      groupadd -r ${user}
      useradd -r -g ${user} --home-dir=${dataDir} ${user}
      mkdir -p ${dataDir}
      chown -R ${user}:${user} ${dataDir}
    '';

    config = {
      Entrypoint = ["bash" "/entrypoint.sh"];
      StopSignal = "SIGINT";
      User = "${user}:${user}";
      Env = ["PGDATA=${dataDir}"];
      WorkingDir = dataDir;
      ExposedPorts = {
        "5432/tcp" = {};
      };
    };
  }
  // {
    meta = with lib; {
      homepage = "https://www.postgresql.org";
      description = "A powerful, open source object-relational database system.";
      platforms = platforms.linux;
      license = licenses.postgresql;
      maintainers = with bonLib.maintainers; [L-Nafaryus];
    };
  }
