{ 
    stdenv, lib, pkgs,
    version ? "1.10.0",
    sha256 ? "sha256-36GAGfvHZyNZe/Z7o3VrCCwApkZpJ+r2E8+1Hy32G5Q=", ...
}:
pkgs.python3.pkgs.buildPythonPackage {
    pname = "dearpygui";
    inherit version;

    src = pkgs.fetchFromGitHub {
        owner = "hoffstadt";
        repo = "DearPyGui";
        rev = "v${version}";
        fetchSubmodules = true;
        sha256 = sha256;
    };

    cmakeFlags = [
        "-DMVDIST_ONLY=True"
    ];

    postConfigure = ''
        cd $cmakeDir
        mv build cmake-build-local
    '';

    nativeBuildInputs = with pkgs; [
        pkg-config
        cmake
    ];

    buildInputs = with pkgs; [
        xorg.libX11.dev
        xorg.libXrandr.dev
        xorg.libXinerama.dev
        xorg.libXcursor.dev
        xorg.xinput
        xorg.libXi.dev
        xorg.libXext
        libxcrypt

        glfw
        glew
    ];

    dontUseSetuptoolsCheck = true;

    pythonImportsCheck = [
        "dearpygui"
    ];

    meta = with pkgs.lib; {
        homepage = "https://dearpygui.readthedocs.io/en/";
        description = "Dear PyGui: A fast and powerful Graphical User Interface Toolkit for Python with minimal dependencies.";
        license = licenses.mit;
        platforms = platforms.linux;
        maintainers = [];
        broken = pkgs.stdenv.isDarwin;
    };
}
