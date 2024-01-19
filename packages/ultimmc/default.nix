{ 
    lib, stdenv,
    fetchFromGitHub, wrapQtAppsHook, 
    extra-cmake-modules, cmake, 
    file, jdk17, 
    copyDesktopItems, makeDesktopItem, 
    xorg, libpulseaudio, libGL
}:
stdenv.mkDerivation rec {
    version = "faf3c966c43465d6f6c245ed78556222240398ee";
    pname = "ultimmc";

    src = fetchFromGitHub {
        fetchSubmodules = true;
        owner = "UltimMC";
        repo = "Launcher";
        rev = "faf3c966c43465d6f6c245ed78556222240398ee";
        sha256 = "sha256-/+cYbAzf84PrgzJHUsc3tVU9E+mDMtx5eGEJK9ZBM2w=";
    };

    nativeBuildInputs = [
        wrapQtAppsHook
        extra-cmake-modules
        cmake
        file
        jdk17
        copyDesktopItems
    ];

    desktopItems = [
        (makeDesktopItem {
            name = "ultimmc";
            desktopName = "UltimMC";
            icon = "ultimmc";
            comment = "Cracked Minecraft launcher";
            exec = "UltimMC %u";
            categories = [ "Game" ];
        })
    ];

    cmakeFlags = [ "-DLauncher_LAYOUT=lin-nodeps" ];
    
    postInstall = let 
        libpath = with xorg; lib.makeLibraryPath [
            libX11
            libXext
            libXcursor
            libXrandr
            libXxf86vm
            libpulseaudio
            libGL
        ];
    in ''
        install -Dm0644 ${src}/notsecrets/logo.svg $out/share/icons/hicolor/scalable/apps/ultimmc.svg

        chmod -x $out/bin/*.so
        wrapProgram $out/bin/UltimMC \
            "''${qtWrapperArgs[@]}" \
            --set GAME_LIBRARY_PATH /run/opengl-driver/lib:${libpath} \
            --prefix PATH : ${lib.makeBinPath [xorg.xrandr]} \
            --add-flags '-d ~/.local/share/ultimmc'

        rm $out/UltimMC
    '';

    meta = with lib; {
        homepage = "https://github.com/UltimMC/Launcher";
        description = "Cracked Minecraft Launcher";
        license = licenses.asl20;
        platforms = platforms.linux;
        maintainers = [] ;
    };
}
