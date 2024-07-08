{
  pkgs,
  lib,
  bonpkgs,
  bonlib,
  extraPaths ? [],
  ...
}:
pkgs.dockerTools.buildImage {
  name = "nix-runner";
  tag = "latest";
  fromImage = bonpkgs.nix-minimal;

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    pathsToLink = ["/bin"];
    paths = with pkgs;
      [
        nodejs
        jq
        cachix
      ]
      ++ extraPaths;
  };

  config.Cmd = ["/bin/bash"];
}
// {
  meta =
    bonpkgs.nix-minimal.meta
    // {
      description = "Image for action runners with a Nix package manager";
      longDescription = ''
        Docker image for action runners with Nix package manager (https://nixos.org/).
        Enabled features: nix-command, flakes.
        Versions: latest
      '';
    };
}
