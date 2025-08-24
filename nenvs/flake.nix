/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "nix envs flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nenvs?dir=env_shell";
    aiagent_base.url = "github:Joelgranados/nenvs?dir=aiagent_base";
  };

  outputs = { self, nixpkgs, env_shell, aiagent_base, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = with pkgs;
        [
          just
        ] ++ aiagent_base.devShells.${system}.default.shellPkgs;
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(NENVS)"
          NIX_ENV_SHELL_ZSHRC_PREFIX="
            cd ~/src/nenvs
          "
        ''
        + aiagent_base.devShells.${system}.default.shellHook
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
