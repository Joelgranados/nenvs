{
  description = "kernel dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          gnumake
          bison
          flex
          ncurses
          (pkgs.python3.withPackages (ppkgs: [
            ppkgs.alabaster
            ppkgs.sphinx
            ppkgs.pyyaml
          ]))
          pahole
          elfutils
          ccache
          bc
          gdb
          openssl
          gcc14
          cpio
          kmod
          zlib
          clang-tools
          coccinelle
          man-pages
          clang-tools
          git-filter-repo
          git
          pkg-config
        ];
        #hardeningDisable = ["fortify"];

        shellHook = ''
          export PATH=${pkgs.ccache}/bin:$PATH
          export CC="ccache gcc"
          export CXX="ccache g++"
          alias make="make CC='"$CC"'"
          export CCACHE_DIR=/home/joel/.cache/.ccache
          mkdir -p $CCACHE_DIR
          echo "ccache configured with directory $CCACHE_DIR"
          export SHELL=$(command -v zsh)
          exec $SHELL
        '';
      };
    };
}
