{ 
    bonfire,
    lib, 
    fetchFromGitHub, buildGoModule, nixosTests, 
    version ? "c847ac4a4c55d6a5a457f6ef494cf45a47299e01",
    hash ? "sha256-g9OxhM+iNUrAZgM1we8qPsismPy5a0eN654tSYuM/No=",
    vendorHash ? "sha256-wG0x86lptEY3x+7kVN7v1XZniliMOxaJ6Y95YS6ivJY=", ...
}:
buildGoModule rec {
    pname = "lego";
    inherit version;

    src = fetchFromGitHub {
        owner = "go-acme";
        repo = "lego";
        rev = version;
        hash = hash;
    };

    inherit vendorHash;

    doCheck = false;

    subPackages = [ "cmd/lego" ];

    ldflags = [
        "-X main.version=${version}"
    ];

    meta = with lib; {
        description = "Let's Encrypt client and ACME library written in Go";
        license = licenses.mit;
        homepage = "https://go-acme.github.io/lego/";
        maintainers = with bonfire.lib.maintainers; [ L-Nafaryus ];
    };

    passthru.tests.lego = nixosTests.acme;
}
