{ ... }:
{
    maintainers = import ./maintainers.nix;

    mkApp = { drv, name ? drv.pname, binPath ? "/bin/${name}" }:
    {
        type = "app";
        program = "${drv}${binPath}";
    };
}
