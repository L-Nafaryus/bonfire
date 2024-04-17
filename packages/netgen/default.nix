{ 
    stdenv, lib, pkgs,
    version ? "6.2.2402",
    sha256 ? "sha256-o3cj5k2VtYiGcs9Z9FyfwtOpDlZZlcO3kRgBSer6KAw=", ...
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
        (python3.withPackages (ps: with ps; [
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

    meta = with pkgs.lib; {
        homepage = "https://github.com/NGSolve/netgen";
        description = "NETGEN is an automatic 3d tetrahedral mesh generator";
        license = licenses.lgpl21Only;
        platforms = platforms.linux;
        maintainers = [];
        broken = pkgs.stdenv.isDarwin;
    };
}
