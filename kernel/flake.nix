/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "kernel shell dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
    kernel_base.url = "github:Joelgranados/nenvs?dir=kernel_base";
    krc.url = "github:Joelgranados/nenvs?dir=krc";
    aiagent_base.url = "github:Joelgranados/nenvs?dir=aiagent_base";
  };

  outputs = { self, nixpkgs, env_shell, kernel_base, krc, aiagent_base, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          krc.packages.${system}.default
        ]
        ++ krc.devShells.${system}.default.shellPkgs
        ++ kernel_base.devShells.${system}.default.shellPkgs
        ++ aiagent_base.devShells.${system}.default.shellPkgs ;

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(KERNEL)"
        ''
        + kernel_base.devShells.${system}.default.shellHook
        + aiagent_base.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
