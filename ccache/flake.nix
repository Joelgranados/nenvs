{
  description = "ccache dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      packages = { ccache_pkg = pkgs.ccache; };
      devShells.${system}.default = pkgs.mkShell {
        shellHook = ''
          export PATH=${pkgs.ccache}/bin:$PATH
          export CC="ccache gcc"
          export CXX="ccache g++"
          alias make="make CC='"$CC"'"
          export CCACHE_DIR=/home/joel/.cache/.ccache
          mkdir -p $CCACHE_DIR
          echo "ccache configured with directory $CCACHE_DIR"
        '';
      };
    };
}
