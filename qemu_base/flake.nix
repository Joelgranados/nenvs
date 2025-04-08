/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "qemu dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    ccache.url = "github:Joelgranados/nix_envs?dir=ccache";
  };

  outputs = { self, nixpkgs, ccache, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = with pkgs;
        [
          gdb
          meson
          glib
          pkg-config
          ninja
          cmake
          lz4
          libslirp
          clang-tools
          b4

          # monitor with vmctl
          socat

          # for b4; must go before python311Full
          python311Packages.requests
          python311Packages.git-filter-repo

          python311Full
        ]
        ++ ccache.devShells.${system}.default.shellPkgs ;
        packages = self.devShells.${system}.default.shellPkgs;
        shellHook = ccache.devShells.${system}.default.shellHook
        ;
      };
    };
}
