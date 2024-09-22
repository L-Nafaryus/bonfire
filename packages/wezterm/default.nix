{
  lib,
  weztermPkgs,
  ...
}:
weztermPkgs.default.overrideAttrs (old: {
  pname = "wezterm";

  meta =
    old.meta
    // {
      homepage = "https://github.com/wez/wezterm";
      description = "A GPU-accelerated cross-platform terminal emulator and multiplexer written by @wez and implemented in Rust";
      license = lib.licenses.mit;
    };
})
