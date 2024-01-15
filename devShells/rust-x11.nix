{ pkgs, cranelib, ... }:
cranelib.devShell {
    packages = with pkgs; [ 
        libGL 
        xorg.libXi xorg.libX11 xorg.libXcursor xorg.libXrandr 
        lld 
        libxkbcommon
        vulkan-loader
    ];

    shellHook = ''
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${
            with pkgs; lib.makeLibraryPath [ 
                libGL 
                xorg.libX11 xorg.libXi xorg.libXcursor xorg.libXrandr 
                libxkbcommon 
                vulkan-loader 
            ]
        }"
    '';
}
