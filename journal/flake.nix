/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "journaling flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
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
          gnumake
          pandoc
          glow # to visualize mark down
          clang-tools
          pyright
          unzip
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(JOURNAL)"
          NIX_ENV_SHELL_ZSHRC_PREFIX="
            cd ~/src/journal
          "
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
