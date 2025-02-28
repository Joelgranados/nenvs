/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "smatch shell dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nix_envs?dir=env_shell";
    kernel_base.url = "github:Joelgranados/nix_envs?dir=kernel_base";
  };

  outputs = { self, nixpkgs, env_shell, kernel_base, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          sqlite
          glibc
        ]
        ++ kernel_base.devShells.${system}.default.shellPkgs ;

        shellHook = ''
          if [[ ! -v _prompt_sorin_prefix ]]; then
            export _prompt_sorin_prefix="%F{green}(S4H)"
          fi
        ''
        + kernel_base.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
