{ 
    pkgs, 
    lib,
    bonlib,
    extraPaths ? [],
    ...
}:
let 
    nixPath = pkgs.writeText "nixpkgsError" ''_: throw '''
        This container doesn't include nixpkgs. 
        Hint: override the NIX_PATH environment variable with eg: 
            "NIX_PATH=nixpkgs=channel:nixos-unstable"
    ''' '';

    builderIds = let forEach = n: if n == 1 then [n] else [n] ++ forEach (n - 1); in forEach 32;

    withFakeNss = with pkgs; [
        (writeTextDir "etc/passwd" (
            builtins.concatStringsSep "\n" (
                map (n: "nixbld${toString n}:x:${toString (30000 + n)}:30000:Nix build user ${toString n}:/var/empty:/bin/false") builderIds)
        + "\n" + ''
            root:x:0:0:System administrator:/root:${bashInteractive}/bin/bash
            nobody:x:65534:65534:Unprivileged account (don't use!):/var/empty:${shadow}/bin/nologin
        ''))

        (writeTextDir "etc/group" ''
            root:x:0:
            wheel:x:1:
            kmem:x:2:
            tty:x:3:
            messagebus:x:4:
            disk:x:6:
            audio:x:17:
            floppy:x:18:
            uucp:x:19:
            lp:x:20:
            cdrom:x:24:
            tape:x:25:
            video:x:26:
            dialout:x:27:
            utmp:x:29:
            adm:x:55:
            keys:x:96:
            users:x:100:
            input:x:174:
            nixbld:x:30000:${builtins.concatStringsSep "," (map (n: "nixbld${toString n}") builderIds)}
            nogroup:x:65534:
        '')

        (writeTextDir "etc/nsswitch.conf" ''
            passwd:    files mymachines systemd
            group:     files mymachines systemd
            shadow:    files

            hosts:     files mymachines dns myhostname
            networks:  files

            ethers:    files
            services:  files
            protocols: files
            rpc:       files
        '')
    ];

    withNixConf = with pkgs; [
        (writeTextDir "etc/nix/nix.conf" ''
            accept-flake-config = true
            experimental-features = nix-command flakes
            show-trace = true 
            max-jobs = auto
            trusted-users = root
        '')
    ];

in pkgs.dockerTools.buildImageWithNixDb {
    name = "nix-minimal";
    tag = "latest";

    copyToRoot = pkgs.buildEnv {
        name = "image-root";
        pathsToLink = [ "/bin" "/etc" ];
        paths = with pkgs; [
            dockerTools.usrBinEnv

            coreutils
            bashInteractive
            nix 

            cacert
            gnutar
            gzip
            xz
            openssh
            ((git.override {
                perlSupport = false;
                pythonSupport = false;
                withpcre2 = false;
                withManual = false;
            }).overrideAttrs (_: { doInstallCheck = false; }))

            iana-etc
        ] ++ withFakeNss ++ withNixConf ++ extraPaths;
    };

    runAsRoot = with pkgs; ''
        #!${runtimeShell}
        ${dockerTools.shadowSetup}
    '';

    config = {
        Cmd = [ "/bin/bash" ];
        Env = [
            "USER=root"
            "PATH=/bin:/usr/bin:/nix/var/nix/profiles/default/bin"
            "PAGER=cat"
            "ENV=/etc/profile.d/nix.sh"
            "BASH_ENV=/etc/profile.d/nix.sh"
            "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
            "NIX_BUILD_SHELL=/bin/bash"
            "NIX_PATH=nixpkgs=${nixPath}"
        ];
    };
} // {
    meta = with lib; {
        homepage = "https://vcs.elnafo.ru/L-Nafaryus/bonfire";
        description = "Minimal image with a Nix package manager";
        longDescription = ''
            Minimal docker image with Nix package manager (https://nixos.org/).
            Enabled features: nix-command, flakes.
            Versions: latest
        '';
        platforms = platforms.linux;
        license = licenses.lgpl21Plus;
        maintainers = with bonlib.maintainers; [ L-Nafaryus ];
    };
}
