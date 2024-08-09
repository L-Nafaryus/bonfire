{
  bonLib,
  lib,
  pkgs,
  ...
}:
(pkgs.blender.override {cudaSupport = true;}).overrideAttrs (old: {
  meta =
    old.meta
    // {
      description = old.meta.description + " (CUDA enabled)";
    };
})
