{
  bonLib,
  stdenv,
  lib,
  pkgs,
  version ? "11.20240116",
  sha256 ? "sha256-bNWlza3cL/lUrwrVEmPECvKbFkwR2rTMaccsn8amGFQ=",
  ...
}: let
  version' = lib.strings.splitString "." version;
  major = lib.elemAt version' 0;
  revision = lib.elemAt version' 1;
  realname = "OpenFOAM";
in let
  pkg = stdenv.mkDerivation {
    pname = "openfoam";
    inherit version major;

    src = pkgs.fetchFromGitHub {
      owner = realname;
      repo = "${realname}-${major}";
      rev = "${revision}";
      sha256 = sha256;
    };

    nativeBuildInputs = with pkgs; [bash m4 flex bison];

    buildInputs = with pkgs; [fftw mpi scotch boost cgal zlib];

    postPatch = ''
      substituteInPlace etc/bashrc \
          --replace '[ "$BASH" -o "$ZSH_NAME" ] && \' '#' \
          --replace 'export FOAM_INST_DIR=$(cd $(dirname ${"$"}{BASH_SOURCE:-$0})/../.. && pwd -P) || \' '#' \
          --replace 'export FOAM_INST_DIR=$HOME/$WM_PROJECT' '# __inst_dir_placeholder__'

      patchShebangs Allwmake
      patchShebangs etc
      patchShebangs wmake
      patchShebangs applications
      patchShebangs bin
    '';

    configurePhase = ''
      export FOAM_INST_DIR=$NIX_BUILD_TOP/source
      export WM_PROJECT_DIR=$FOAM_INST_DIR/${realname}-${major}
      mkdir $WM_PROJECT_DIR

      mv $(find $FOAM_INST_DIR/ -maxdepth 1 -not -path $WM_PROJECT_DIR -not -path $FOAM_INST_DIR/) \
          $WM_PROJECT_DIR/

      set +e
      . $WM_PROJECT_DIR/etc/bashrc
      set -e
    '';

    buildPhase = ''
      sh $WM_PROJECT_DIR/Allwmake -j$CORES
      wclean all
      wmakeLnIncludeAll
    '';

    installPhase = ''
      mkdir -p $out/${realname}-${major}

      substituteInPlace $WM_PROJECT_DIR/etc/bashrc \
          --replace '# __inst_dir_placeholder__' "export FOAM_INST_DIR=$out"

      cp -Ra $WM_PROJECT_DIR/* $out/${realname}-${major}
    '';

    passthru = {
      shellHook = ''
        . ${pkg}/${realname}-${major}/etc/bashrc
      '';
    };

    meta = with pkgs.lib; {
      homepage = "https://www.openfoam.org/";
      description = "OpenFOAM is a free, open source CFD software released and developed by OpenFOAM Foundation";
      license = licenses.gpl3;
      platforms = platforms.linux;
      maintainers = with bonLib.maintainers; [L-Nafaryus];
      broken = pkgs.stdenv.isDarwin;
    };
  };
in
  pkg
