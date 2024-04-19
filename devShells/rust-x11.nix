{ pkgs, crane-lib, ... }:
crane-lib.devShell rec {
    packages = with pkgs; [ 
        lld 
        pkg-config 
        libGL 
        vulkan-loader
        vulkan-headers 
        vulkan-tools 
        vulkan-validation-layers
        xorg.libXi 
        xorg.libX11 
        xorg.libXcursor 
        xorg.libXrandr 
        libxkbcommon
        libudev-zero 
        alsa-lib 
    ];

    shellHook = ''
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath packages}"
    '';
}
