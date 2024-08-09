{
  lib,
  bonLib,
  pkgs,
  version ? "9fcd8f830ebde2491719a5c698e22d1d5210e0fb",
  hash ? "sha256-8cqKCNYLLkZXlwrybKUPG6fLd7gmf8zV9tjWoTxAwIY=",
  ...
}:
pkgs.stdenv.mkDerivation {
  pname = "zapret";
  inherit version;

  src = pkgs.fetchFromGitHub {
    owner = "bol-van";
    repo = "zapret";
    rev = version;
    hash = hash;
  };

  buildInputs = with pkgs; [libcap zlib libnetfilter_queue libnfnetlink];
  nativeBuildInputs = with pkgs; [iptables nftables gawk];

  buildPhase = ''
    mkdir -p $out/bin

    make TGT=$out/bin
  '';

  installPhase = ''
    mkdir -p $out/usr/share/zapret/init.d/sysv
    mkdir -p $out/usr/share/docs

    cp $src/blockcheck.sh $out/bin/blockcheck

    substituteInPlace $out/bin/blockcheck \
      --replace "ZAPRET_BASE=\"\$EXEDIR\"" "ZAPRET_BASE=$out/usr/share/zapret"

    cp $src/init.d/sysv/functions $out/usr/share/zapret/init.d/sysv/functions
    cp $src/init.d/sysv/zapret $out/usr/share/zapret/init.d/sysv/init.d

    substituteInPlace $out/usr/share/zapret/init.d/sysv/functions \
      --replace "ZAPRET_BASE=\$(readlink -f \"\$EXEDIR/../..\")" "ZAPRET_BASE=$out/usr/share/zapret" \
      --replace ". \"\$ZAPRET_BASE/config\"" ""

    cp -r $src/docs/* $out/usr/share/docs

    mkdir -p $out/usr/share/zapret/{common,ipset}

    cp $src/common/* $out/usr/share/zapret/common
    cp $src/ipset/* $out/usr/share/zapret/ipset

    mkdir -p $out/usr/share/zapret/nfq
    ln -s ../../../../bin/nfqws $out/usr/share/zapret/nfq/nfqws

    for i in ip2net mdig tpws
    do
      mkdir -p $out/usr/share/zapret/$i
      ln -s ../../../../bin/$i $out/usr/share/zapret/$i/$i
    done

    ln -s ../usr/share/zapret/init.d/sysv/init.d $out/bin/zapret
  '';

  passthru = {
    antifilter = {
      ipsmart = pkgs.fetchurl {
        url = "https://antifilter.network/download/ipsmart.lst";
        hash = "sha256-mg2OFZ3x2q/31wNMZl6R6bTK0TKenSFePRo+B1GJdwo=";
      };
    };
  };

  meta = with lib; {
    description = "DPI bypass multi platform";
    homepage = "https://github.com/bol-van/zapret";
    license = licenses.mit;
    maintainers = with bonLib.maintainers; [L-Nafaryus];
    mainProgram = "zapret";
    broken = false;
  };
}
