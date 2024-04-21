{
    bonfire,
    crane-lib,
    lib,
    pkgs,
    fetchFromGitHub,
    version ? "v0.43.0",
    hash ? "sha256-wMtB7oWcbLQ3E0R6b2QbEHSeOYwZgeUuiwJlL8W9wlI=",
    ...
}:
crane-lib.buildPackage {
    pname = "cargo-shuttle";
    inherit version;

    src = fetchFromGitHub {
        owner = "shuttle-hq";
        repo = "shuttle";
        rev = version;
        hash = hash;
    };

    strictDeps = true;

    nativeBuildInputs = with pkgs; [
        pkg-config
    ];

    buildInputs = with pkgs; [
        openssl
        zlib
    ];

    meta = with lib; {
        description = "A cargo command for the shuttle platform";
        license = licenses.asl20;
        homepage = "https://shuttle.rs/";
        maintainers = with bonfire.lib.maintainers; [ L-Nafaryus ];
        broken = true;
    };
}
