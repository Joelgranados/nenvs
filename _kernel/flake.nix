{
  description = "kernel dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_ccache.url = "github:Joelgranados/nix_envs?dir=ccache";
  };

  outputs = { self, nixpkgs, env_ccache, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = with pkgs;
        [
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

          # These are for gcc-plugins to work
          gmp
          libmpc
          mpfr
          mutagen
        ] ++ env_ccache.devShells.${system}.default.shellPkgs ;
        packages = self.devShells.${system}.default.shellPkgs;
        shellHook = env_ccache.devShells.${system}.default.shellHook;
      };
    };
}
