/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "kernel dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    ccache.url = "github:Joelgranados/nenvs?dir=ccache";
    toolchain_ctl.url = "github:Joelgranados/toolchain_ctl";
    semcode.url = "github:Joelgranados/semcode?ref=61e5e4fbefc758b5f2b0c8216318fc3cb9d903cf";
  };

  outputs = { self, nixpkgs, ccache, toolchain_ctl, semcode, ... }:
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
          bash-language-server
          coccinelle
          man-pages
          git-filter-repo
          git
          pkg-config
          b4
          virtiofsd
          perl

          # These are for gcc-plugins to work
          gmp
          libmpc
          mpfr

          # to send mails with b4
          msmtp

          toolchain_ctl.packages.${system}.default
          semcode.packages.${pkgs.system}.default

        ] ++ ccache.devShells.${system}.default.shellPkgs ;
        packages = self.devShells.${system}.default.shellPkgs;
        shellHook = ccache.devShells.${system}.default.shellHook;
      };
    };
}
