/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "qemu shell dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nix_envs?dir=env_shell";
    env_qemu.url = "github:Joelgranados/nix_envs?dir=_qemu";
    krc.url = "github:Joelgranados/nix_envs?dir=krc";
  };

  outputs = { self, nixpkgs, env_shell, env_qemu, krc, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          krc.packages.${system}.default
        ]
        ++ krc.devShells.${system}.default.shellPkgs
        ++ env_qemu.devShells.${system}.default.shellPkgs ;

        shellHook = ''
          if [[ ! -v _prompt_sorin_prefix ]]; then
            export _prompt_sorin_prefix="%F{green}(QEMU)"
          fi
        ''
        + env_qemu.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
