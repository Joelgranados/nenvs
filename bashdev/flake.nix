/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "bash development flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
  };

  outputs = { self, nixpkgs, env_shell, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = with pkgs;
        [
          bash
          bash-language-server
          shellcheck
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(BASHDEV)"
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
