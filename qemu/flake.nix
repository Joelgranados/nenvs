/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "qemu dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nix_envs?dir=env_shell";
    env_ccache.url = "github:Joelgranados/nix_envs?dir=ccache";
  };

  outputs = { self, nixpkgs, env_shell, env_ccache, ... }:
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
        ] ++ env_ccache.devShells.${system}.default.shellPkgs ;
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          if [[ ! -v _prompt_sorin_prefix ]]; then
            export _prompt_sorin_prefix="%F{green}(Q2U)"
          fi
        ''
        + env_ccache.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
