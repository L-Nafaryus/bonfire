# Packages

First, you need to add this project to your flake inputs:

```nix
{
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        bonfire.url = "github:L-Nafaryus/bonfire";
    };
    outputs = { nixpkgs, bonfire, ... }:
    { ... }
}
```

After, you can use in a NixOS configuration like so 

```nix 
{
    nixosConfigurations.foo = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { bonPkgs = bonfire.packages.x86_64-linux; };
        modules = [
            { pkgs, bonPkgs, ... }: {
                environment.systemPackages = [
                    pkgs.bar 
                    bonPkgs.baz
                ];
            }
            ...
        ];
    };
    # or pass in your devShells, nixosModules, etc
}
```

