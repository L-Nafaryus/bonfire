{
  bonLib,
  stdenv,
  pkgs,
  version ? "6.2.2405",
  sha256 ? "sha256-SZPZT49BqUzssPcOo/5yAkjqAHDErC86xCUFL88Iew4=",
  lib,
  ...
}:
stdenv.mkDerivation {
  pname = "netgen";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "NGSolve";
    repo = "netgen";
    rev = "v${version}";
    sha256 = sha256;
  };

  patches = [
    ./regex-version.patch
  ];

  cmakeFlags = [
    "-G Ninja"
    "-D CMAKE_BUILD_TYPE=Release"
    "-D USE_NATIVE_ARCH:BOOL=OFF"
    "-D USE_OCC:BOOL=ON"
    "-D USE_PYTHON:BOOL=ON"
    "-D USE_GUI:BOOL=ON"
    "-D USE_MPI:BOOL=ON"
    "-D USE_SUPERBUILD:BOOL=OFF"
    "-D PREFER_SYSTEM_PYBIND11:BOOL=ON"
  ];

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    git
    (python3.withPackages (ps:
      with ps; [
        pybind11
        mpi4py
      ]))
  ];

  buildInputs = with pkgs; [
    zlib
    tcl
    tk
    mpi
    opencascade-occt
    libGL
    libGLU
    xorg.libXmu
    metis
  ];

  passthru = {
    shellHook = with pkgs; ''
      export PYTHONPATH="${python3}/${python3.sitePackages}"
      export PYTHONPATH="$PYTHONPATH:${pkg}/${python3.sitePackages}"
    '';
    update = pkgs.writeShellScriptBin "update-spoofdpi" ''
      set -euo pipefail

      new_version=$(${lib.getExe pkgs.curl} -s "https://api.github.com/repos/NGSolve/netgen/tags?per_page=1" | ${lib.getExe pkgs.jq} -r ".[0].name")
      new_hash=$(nix flake prefetch --json https://github.com/NGSolve/netgen/archive/refs/tags/$new_version.tar.gz | ${lib.getExe pkgs.jq} -r ".hash")

      old_version=$(nix eval --impure --json --expr "(builtins.getFlake (toString ./.)).packages.${builtins.currentSystem}.netgen.version")
      old_hash=$(nix eval --impure --json --expr "(builtins.getFlake (toString ./.)).packages.${builtins.currentSystem}.netgen.src.outputHash")

      nixpath=$(nix eval --impure --json --expr "(builtins.getFlake (toString ./.)).packages.${builtins.currentSystem}.netgen.src.meta.position")
      relpath=$(echo $nixpath | ${lib.getExe pkgs.ripgrep} "\/nix\/store\/[\w\d]{32}-[^\/]+/" -r "" | ${lib.getExe pkgs.ripgrep} "[:\d]" -r "")
      #echo "./$relpath" | ${lib.getExe pkgs.gnused} -i "s/$old_version/$new_version/g"
      #echo "./$relpath" | ${lib.getExe pkgs.gnused} -i "s/$old_hash/$new_hash/g"

      content=$(${lib.getExe pkgs.ripgrep} $old_version --passthru -r $new_version $relpath)
      content=$(echo $content | ${lib.getExe pkgs.ripgrep} $old_version --passthru -r $new_version $relpath)

      echo $content > $relpath
      # TODO: убрать все кавычки
    '';
  };

  meta = with pkgs.lib; {
    homepage = "https://github.com/NGSolve/netgen";
    description = "NETGEN is an automatic 3d tetrahedral mesh generator";
    license = licenses.lgpl21Only;
    platforms = platforms.linux;
    maintainers = with bonLib.maintainers; [L-Nafaryus];
    broken = false;
  };
}
