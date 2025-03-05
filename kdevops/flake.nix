/* SPDX-License-Identifier: GPL-3.0-only */

{
  description = "kdevops dev flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    env_shell.url = "github:Joelgranados/nix_envs?dir=env_shell";
    kernel.url = "github:Joelgranados/nix_envs?dir=kernel";
  };

  outputs = { self, nixpkgs, env_shell, kernel, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
      system = "x86_64-linux";
    in {
      devShells.${system}.default = pkgs.mkShell {

      shellPkgs = with pkgs;
        [ ansible libguestfs ] ++ kernel.devShells.${system}.default.shellPkgs ;
      packages = self.devShells.${system}.default.shellPkgs;

      shellHook = ''
        NIX_ENV_SHELL_PROMPT_PREFIX="%F{green}(K5S)"
      ''
        + kernel.devShells.${system}.default.shellHook ;
    };
  };
}
