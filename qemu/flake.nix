/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "qemu shell dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
    qemu_base.url = "github:Joelgranados/nenvs?dir=qemu_base";
    krc.url = "github:Joelgranados/nenvs?dir=krc";
    aiagent_base.url = "github:Joelgranados/nenvs?dir=aiagent_base";
  };

  outputs = { self, nixpkgs, env_shell, qemu_base, krc, aiagent_base, ... }:
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
        ++ qemu_base.devShells.${system}.default.shellPkgs
        ++ aiagent_base.devShells.${system}.default.shellPkgs ;

        hardeningDisable = ["fortify"];

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(QEMU)"
        ''
        + qemu_base.devShells.${system}.default.shellHook
        + aiagent_base.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
