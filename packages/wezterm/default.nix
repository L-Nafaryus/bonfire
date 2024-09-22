{
  bonLib,
  craneLib,
  lib,
  pkgs,
  version ? "2d0c5cddc91a9c59aef9a7667d90924e7cedd0ac",
  hash ? "sha256-ZsDJQSUokodwFMP4FIZm2dYojf5iC4F/EeKC5VuQlqY=",
  ...
}: let
  src = pkgs.fetchFromGitHub {
    owner = "wez";
    repo = "wezterm";
    rev = version;
    hash = hash;
    fetchSubmodules = true;
  };
  terminfo =
    pkgs.runCommand "wezterm-terminfo"
    {
      nativeBuildInputs = [pkgs.ncurses];
    } ''
      mkdir -p $out/share/terminfo $out/nix-support
      tic -x -o $out/share/terminfo ${src}/termwiz/data/wezterm.terminfo
    '';
  pkg = {
    pname = "wezterm";
    inherit version;

    inherit src;

    strictDeps = true;
    doCheck = false;

    nativeBuildInputs = with pkgs; [
      installShellFiles
      ncurses # tic for terminfo
      pkg-config
      python3
    ];

    buildInputs = with pkgs; [
      fontconfig
      pkgs.zlib
      libxkbcommon
      openssl
      wayland
      cairo

      xorg.libX11
      xorg.libxcb
      xorg.xcbutil
      xorg.xcbutilimage
      xorg.xcbutilkeysyms
      xorg.xcbutilwm # contains xcb-ewmh among others
    ];

    libPath = lib.makeLibraryPath (with pkgs; [
      xorg.xcbutilimage
      libGL
      vulkan-loader
    ]);

    postPatch = ''
      echo ${version} > .tag

      # tests are failing with: Unable to exchange encryption keys
      # rm -r wezterm-ssh/tests
    '';

    preFixup = lib.optionalString pkgs.stdenv.isLinux ''
      patchelf \
        --add-needed "${pkgs.libGL}/lib/libEGL.so.1" \
        --add-needed "${pkgs.vulkan-loader}/lib/libvulkan.so.1" \
        $out/bin/wezterm-gui
    '';

    postInstall = ''
      mkdir -p $out/nix-support
      echo "${terminfo}" >> $out/nix-support/propagated-user-env-packages

      install -Dm644 assets/icon/terminal.png $out/share/icons/hicolor/128x128/apps/org.wezfurlong.wezterm.png
      install -Dm644 assets/wezterm.desktop $out/share/applications/org.wezfurlong.wezterm.desktop
      install -Dm644 assets/wezterm.appdata.xml $out/share/metainfo/org.wezfurlong.wezterm.appdata.xml

      install -Dm644 assets/shell-integration/wezterm.sh -t $out/etc/profile.d
      installShellCompletion --cmd wezterm \
        --bash assets/shell-completion/bash \
        --fish assets/shell-completion/fish \
        --zsh assets/shell-completion/zsh

      install -Dm644 assets/wezterm-nautilus.py -t $out/share/nautilus-python/extensions
    '';

    meta = with lib; {
      homepage = "https://github.com/wez/wezterm";
      description = "A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust";
      license = lib.licenses.mit;
      maintainers = with bonLib.maintainers; [L-Nafaryus];
      platforms = platforms.x86_64;
      mainProgram = "wezterm";
    };
  };
in let
  cargoArtifacts = craneLib.buildDepsOnly pkg;
in
  craneLib.buildPackage (
    pkg // {inherit cargoArtifacts;}
  )
