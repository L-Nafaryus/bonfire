<p align="center">
    <a href="https://github.com/L-Nafaryus/bonfire">
        <img src="https://raw.githubusercontent.com/L-Nafaryus/bonfire/master/etc/bonfire-logo.png" width="500px" alt="bonfire-logo"/>
    </a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/nix%20flake-gray.svg?logo=nixos" alt="nix-flake"/>
  <a href="https://bonfire.cachix.org"><img src="https://img.shields.io/badge/cachix-bonfire-orange.svg" alt="bonfire-cachix" /></a>
</p>

<p align="center">
    <strong><em>Lit another Nix derivation</em></strong>
</p>

> This is a private configuration and experiment with Nix and NixOS. Formally 
> it's a more than just a dotfiles in cause of packages, modules, templates and 
> etc. Discover the current repository on your own risk.

# Hints 

* Update and push inputs:
```sh 
nix flake update 
nix flake archive --json \
    | jq -r '.path,(.inputs|to_entries[].value.path)' \
    | cachix push bonfire
```

* Build and push package:
```sh 
nix build --json .#package \
    | jq -r '.[].outputs | to_entries[].value' \
    | cachix push bonfire 
```

* Rebuild system with git submodules:
```sh 
nixos-rebuild switch --flake ".?submodules=1#astora"
```

* Rebuild remote system from local system with git submodules:
```sh 
nixos-rebuild switch --flake ".?submodules=1#catarina" --build-host l-nafaryus@astora --target-host l.nafaryus@catarina --use-remote-sudo
```

# License


**bonfire** is licensed under the [MIT License](LICENSE).

> MIT license does not apply to the packages built by **Nix**, merely to the files
> in this repository. It also might not apply to patches included in **Nix**, which 
> may be derivative works of the packages to which they apply. The aforementioned 
> artifacts are all covered by the licenses of the respective packages.
