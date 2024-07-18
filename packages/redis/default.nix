{
  pkgs,
  lib,
  bonLib,
  extraPaths ? [],
  ...
}: let
  user = "redis";
  dataDir = "/var/lib/redis";
  entryPoint = pkgs.writeTextDir "entrypoint.sh" ''
    redis-server \
        --daemonize no \
        --dir "${dataDir}"
  '';
in
  pkgs.dockerTools.buildImage {
    name = "redis";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      pathsToLink = ["/bin" "/etc" "/"];
      paths = with pkgs;
        [
          bash
          redis
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
      WorkingDir = dataDir;
      ExposedPorts = {
        "6379/tcp" = {};
      };
    };
  }
  // {
    meta = with lib; {
      homepage = "https://redis.io";
      description = "An open source, advanced key-value store.";
      platforms = platforms.linux;
      license = licenses.bsd3;
      maintainers = with bonLib.maintainers; [L-Nafaryus];
    };
  }
