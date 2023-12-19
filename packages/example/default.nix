{ stdenv, lib, pkgs, ... }:
stdenv.mkDerivation {
    pname = "example";
    version = "1.0";

    # local source
    src = ./.;

    nativeBuildInputs = with pkgs; [ cmake ninja ];

    meta = with lib; {
        homepage = "https://www.example.org/";
        description = "Example with hello nix.";
        license = licenses.cc0;
        platforms = platforms.linux;
        maintainers = [];
        broken = false;
    };
}
