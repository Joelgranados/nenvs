/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "kernel dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    ccache.url = "github:Joelgranados/nix_envs?dir=ccache";
    toolchain_ctl.url = "github:Joelgranados/toolchain_ctl";
  };

  outputs = { self, nixpkgs, ccache, toolchain_ctl, ... }:
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
            ppkgs.ply
            ppkgs.gitpython
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
          git-filter-repo
          git
          pkg-config
          b4

          # These are for gcc-plugins to work
          gmp
          libmpc
          mpfr

          toolchain_ctl.packages.${system}.default
        ] ++ ccache.devShells.${system}.default.shellPkgs ;
        packages = self.devShells.${system}.default.shellPkgs;
        shellHook = ccache.devShells.${system}.default.shellHook;
      };
    };
}
