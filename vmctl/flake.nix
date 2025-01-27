/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "vmctl flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nix_envs?dir=env_shell";
  };

  outputs = { self, nixpkgs, env_shell, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {
        shellPkgs = with pkgs;
        [
          cdrtools
          bash
        ];
        packages = self.devShells.${system}.default.shellPkgs;

        shellHook = ''
          export _prompt_sorin_prefix="%F{green}(V3L)"
        ''
        + env_shell.devShells.${system}.default.shellHook
        ;
      };
    };
}
