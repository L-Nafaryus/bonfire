# Side Notes

* How to update and push flake inputs:

```sh 
nix flake update 
nix flake archive --json \
    | jq -r '.path,(.inputs|to_entries[].value.path)' \
    | cachix push bonfire
```

* How to build and push flake package:

```sh 
nix build --json .#package \
    | jq -r '.[].outputs | to_entries[].value' \
    | cachix push bonfire 
```

* How to rebuild system with git submodules:

```sh 
sudo nixos-rebuild switch --flake ".?submodules=1#astora"
```

* How to rebuild remote system from local system with git submodules:

```sh 
nixos-rebuild switch --flake ".?submodules=1#catarina" --build-host l-nafaryus@astora --target-host l.nafaryus@catarina --use-remote-sudo
```


