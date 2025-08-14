/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "claude dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
  };

  outputs = { self, nixpkgs, env_shell, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = [
          pkgs.claude-code
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(CLAUDE)"
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}