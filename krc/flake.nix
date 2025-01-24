{
  description = "Kerne environment Remote Command (krc)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }:.
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in
  {
    packages.${system}.default = pkgs.stdenv.mkDerivation {
      pname = "krc";
      version = "0.0.1";
      src = ./.;
      installPhase = ''
        mkdir -p $out/bin
        cp krc $out/bin/krc
        chmod +x $out/bin/krc
      '';
    };
  };
}

