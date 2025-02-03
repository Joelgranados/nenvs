/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "qemu dev flake";

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
          meson
          glib
          pkg-config
          ninja
          cmake
          lz4
          libslirp
          clang-tools
        ]
        ++ env_ccache.devShells.${system}.default.shellPkgs ;
        packages = self.devShells.${system}.default.shellPkgs;
        shellHook = env_ccache.devShells.${system}.default.shellHook
        ;
      };
    };
}
